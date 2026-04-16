# frozen_string_literal: true

module Finance
  class CapitalGainsTaxCalculator
    attr_reader :errors

    FILING_STATUSES = %w[single married_jointly married_separately head_of_household].freeze

    # 2024 long-term capital gains thresholds
    LONG_TERM_THRESHOLDS = {
      "single" => { zero_max: 47_025, fifteen_max: 518_900 },
      "married_jointly" => { zero_max: 94_050, fifteen_max: 583_750 },
      "married_separately" => { zero_max: 47_025, fifteen_max: 291_850 },
      "head_of_household" => { zero_max: 63_000, fifteen_max: 551_350 }
    }.freeze

    # NIIT thresholds
    NIIT_THRESHOLDS = {
      "single" => 200_000,
      "married_jointly" => 250_000,
      "married_separately" => 125_000,
      "head_of_household" => 200_000
    }.freeze

    NIIT_RATE = 0.038

    # 2024 federal ordinary income tax brackets
    ORDINARY_BRACKETS = {
      "single" => [
        { max: 11_600, rate: 0.10 },
        { max: 47_150, rate: 0.12 },
        { max: 100_525, rate: 0.22 },
        { max: 191_950, rate: 0.24 },
        { max: 243_725, rate: 0.32 },
        { max: 609_350, rate: 0.35 },
        { max: Float::INFINITY, rate: 0.37 }
      ],
      "married_jointly" => [
        { max: 23_200, rate: 0.10 },
        { max: 94_300, rate: 0.12 },
        { max: 201_050, rate: 0.22 },
        { max: 383_900, rate: 0.24 },
        { max: 487_450, rate: 0.32 },
        { max: 731_200, rate: 0.35 },
        { max: Float::INFINITY, rate: 0.37 }
      ],
      "married_separately" => [
        { max: 11_600, rate: 0.10 },
        { max: 47_150, rate: 0.12 },
        { max: 100_525, rate: 0.22 },
        { max: 191_950, rate: 0.24 },
        { max: 243_725, rate: 0.32 },
        { max: 365_600, rate: 0.35 },
        { max: Float::INFINITY, rate: 0.37 }
      ],
      "head_of_household" => [
        { max: 16_550, rate: 0.10 },
        { max: 63_100, rate: 0.12 },
        { max: 100_500, rate: 0.22 },
        { max: 191_950, rate: 0.24 },
        { max: 243_700, rate: 0.32 },
        { max: 609_350, rate: 0.35 },
        { max: Float::INFINITY, rate: 0.37 }
      ]
    }.freeze

    def initialize(purchase_price:, sale_price:, holding_period_months:, annual_income:, filing_status:)
      @purchase_price = purchase_price.to_f
      @sale_price = sale_price.to_f
      @holding_period_months = holding_period_months.to_i
      @annual_income = annual_income.to_f
      @filing_status = filing_status.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      capital_gain = @sale_price - @purchase_price
      is_long_term = @holding_period_months > 12

      if capital_gain <= 0
        return {
          valid: true,
          capital_gain: capital_gain.round(2),
          is_long_term: is_long_term,
          tax_rate: 0.0,
          tax_owed: 0.0,
          niit_owed: 0.0,
          net_profit: capital_gain.round(2),
          effective_rate: 0.0
        }
      end

      if is_long_term
        tax_rate = long_term_rate
        tax_owed = capital_gain * tax_rate
      else
        tax_rate = marginal_ordinary_rate
        tax_owed = calculate_short_term_tax(capital_gain)
      end

      niit_owed = calculate_niit(capital_gain)
      total_tax = tax_owed + niit_owed
      net_profit = capital_gain - total_tax
      effective_rate = capital_gain > 0 ? (total_tax / capital_gain * 100) : 0.0

      {
        valid: true,
        capital_gain: capital_gain.round(2),
        is_long_term: is_long_term,
        tax_rate: (tax_rate * 100).round(2),
        tax_owed: tax_owed.round(2),
        niit_owed: niit_owed.round(2),
        net_profit: net_profit.round(2),
        effective_rate: effective_rate.round(2)
      }
    end

    private

    def validate!
      @errors << "Purchase price must be positive" unless @purchase_price > 0
      @errors << "Sale price must be positive" unless @sale_price > 0
      @errors << "Holding period must be positive" unless @holding_period_months > 0
      @errors << "Annual income cannot be negative" if @annual_income < 0
      @errors << "Invalid filing status" unless FILING_STATUSES.include?(@filing_status)
    end

    def long_term_rate
      thresholds = LONG_TERM_THRESHOLDS[@filing_status]
      taxable = @annual_income + (@sale_price - @purchase_price)

      if taxable <= thresholds[:zero_max]
        0.0
      elsif taxable <= thresholds[:fifteen_max]
        0.15
      else
        0.20
      end
    end

    def marginal_ordinary_rate
      brackets = ORDINARY_BRACKETS[@filing_status]
      total_income = @annual_income + (@sale_price - @purchase_price)
      rate = 0.10

      brackets.each do |bracket|
        if total_income <= bracket[:max]
          rate = bracket[:rate]
          break
        end
      end

      rate
    end

    def calculate_short_term_tax(capital_gain)
      # Tax the gain at ordinary income rates starting from the existing income level
      brackets = ORDINARY_BRACKETS[@filing_status]
      remaining_gain = capital_gain
      tax = 0.0
      prev_max = 0

      brackets.each do |bracket|
        bracket_top = bracket[:max]
        bracket_bottom = prev_max

        if @annual_income >= bracket_top
          prev_max = bracket_top
          next
        end

        taxable_start = [ @annual_income, bracket_bottom ].max
        taxable_end = [ bracket_top, @annual_income + remaining_gain ].min
        taxable_in_bracket = taxable_end - taxable_start

        if taxable_in_bracket > 0
          tax += taxable_in_bracket * bracket[:rate]
          remaining_gain -= taxable_in_bracket
        end

        prev_max = bracket_top
        break if remaining_gain <= 0
      end

      tax
    end

    def calculate_niit(capital_gain)
      threshold = NIIT_THRESHOLDS[@filing_status]
      total_income = @annual_income + capital_gain

      if total_income > threshold
        # NIIT applies to the lesser of: net investment income or amount over threshold
        excess = total_income - threshold
        niit_base = [ capital_gain, excess ].min
        niit_base * NIIT_RATE
      else
        0.0
      end
    end
  end
end
