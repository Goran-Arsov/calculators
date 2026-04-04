module Finance
  class TaxBracketCalculator
    attr_reader :errors

    BRACKETS = {
      "single" => [
        { min: 0,       max: 11_600,   rate: 0.10 },
        { min: 11_601,  max: 47_150,   rate: 0.12 },
        { min: 47_151,  max: 100_525,  rate: 0.22 },
        { min: 100_526, max: 191_950,  rate: 0.24 },
        { min: 191_951, max: 243_725,  rate: 0.32 },
        { min: 243_726, max: 609_350,  rate: 0.35 },
        { min: 609_351, max: Float::INFINITY, rate: 0.37 }
      ],
      "married_filing_jointly" => [
        { min: 0,       max: 23_200,   rate: 0.10 },
        { min: 23_201,  max: 94_300,   rate: 0.12 },
        { min: 94_301,  max: 201_050,  rate: 0.22 },
        { min: 201_051, max: 383_900,  rate: 0.24 },
        { min: 383_901, max: 487_450,  rate: 0.32 },
        { min: 487_451, max: 731_200,  rate: 0.35 },
        { min: 731_201, max: Float::INFINITY, rate: 0.37 }
      ],
      "married_filing_separately" => [
        { min: 0,       max: 11_600,   rate: 0.10 },
        { min: 11_601,  max: 47_150,   rate: 0.12 },
        { min: 47_151,  max: 100_525,  rate: 0.22 },
        { min: 100_526, max: 191_950,  rate: 0.24 },
        { min: 191_951, max: 243_725,  rate: 0.32 },
        { min: 243_726, max: 609_350,  rate: 0.35 },
        { min: 609_351, max: Float::INFINITY, rate: 0.37 }
      ],
      "head_of_household" => [
        { min: 0,       max: 16_550,   rate: 0.10 },
        { min: 16_551,  max: 63_100,   rate: 0.12 },
        { min: 63_101,  max: 100_500,  rate: 0.22 },
        { min: 100_501, max: 191_950,  rate: 0.24 },
        { min: 191_951, max: 243_700,  rate: 0.32 },
        { min: 243_701, max: 609_350,  rate: 0.35 },
        { min: 609_351, max: Float::INFINITY, rate: 0.37 }
      ]
    }.freeze

    VALID_STATUSES = BRACKETS.keys.freeze

    def initialize(income:, filing_status:)
      @income = income.to_f
      @filing_status = filing_status.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      brackets = BRACKETS[@filing_status]
      breakdown = []
      remaining = @income
      total_tax = 0.0

      brackets.each do |bracket|
        break if remaining <= 0

        bracket_min = bracket[:min]
        bracket_max = bracket[:max]
        rate = bracket[:rate]

        taxable_in_bracket = if @income > bracket_max
                               bracket_max - bracket_min + 1
        else
                               remaining
        end

        # For the first bracket, the width is max - min + 1 (e.g., 0..11600 = 11601)
        # But we need to handle the first bracket specially since min is 0
        bracket_width = if bracket_min == 0
                          bracket_max + 1
        else
                          bracket_max - bracket_min + 1
        end
        bracket_width = bracket_width.infinite? ? remaining : bracket_width

        taxable_in_bracket = [ remaining, bracket_width ].min
        tax_in_bracket = taxable_in_bracket * rate

        breakdown << {
          rate: (rate * 100).round(0),
          range_min: bracket_min,
          range_max: bracket_max == Float::INFINITY ? nil : bracket_max,
          taxable_amount: taxable_in_bracket.round(2),
          tax: tax_in_bracket.round(2)
        }

        total_tax += tax_in_bracket
        remaining -= taxable_in_bracket
      end

      effective_rate = @income > 0 ? (total_tax / @income * 100) : 0.0
      marginal_rate = find_marginal_rate(brackets)

      {
        valid: true,
        income: @income.round(2),
        filing_status: @filing_status,
        total_tax: total_tax.round(2),
        effective_rate: effective_rate.round(2),
        marginal_rate: marginal_rate,
        after_tax_income: (@income - total_tax).round(2),
        breakdown: breakdown.select { |b| b[:taxable_amount] > 0 }
      }
    end

    private

    def validate!
      @errors << "Taxable income must be positive" unless @income > 0
      @errors << "Filing status is not valid" unless VALID_STATUSES.include?(@filing_status)
    end

    def find_marginal_rate(brackets)
      brackets.each do |bracket|
        if @income <= bracket[:max] || bracket[:max] == Float::INFINITY
          return (bracket[:rate] * 100).round(0)
        end
      end
      37
    end
  end
end
