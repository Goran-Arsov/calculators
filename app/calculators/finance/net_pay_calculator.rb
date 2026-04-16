# frozen_string_literal: true

module Finance
  class NetPayCalculator
    attr_reader :errors

    # Simplified multi-country take-home pay calculator
    # country: "us", "uk", "ca", "au"
    # pay_frequency: "annual", "monthly", "biweekly", "weekly"
    def initialize(gross_salary:, country: "us", filing_status: "single", pay_frequency: "annual")
      @gross_salary = gross_salary.to_f
      @country = country.to_s.downcase
      @filing_status = filing_status.to_s.downcase
      @pay_frequency = pay_frequency.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      deductions = calculate_deductions
      total_deductions = deductions.values.sum
      net_annual = @gross_salary - total_deductions
      effective_rate = (total_deductions / @gross_salary) * 100.0

      periods = pay_periods
      net_per_period = net_annual / periods
      gross_per_period = @gross_salary / periods

      {
        valid: true,
        gross_salary: @gross_salary.round(2),
        net_annual: net_annual.round(2),
        net_per_period: net_per_period.round(2),
        gross_per_period: gross_per_period.round(2),
        total_deductions: total_deductions.round(2),
        effective_tax_rate: effective_rate.round(2),
        deductions: deductions.transform_values { |v| v.round(2) },
        country: @country,
        pay_frequency: @pay_frequency,
        pay_periods: periods
      }
    end

    private

    def validate!
      @errors << "Gross salary must be positive" unless @gross_salary > 0
      @errors << "Country must be us, uk, ca, or au" unless %w[us uk ca au].include?(@country)
      @errors << "Filing status must be single or married" unless %w[single married].include?(@filing_status)
      @errors << "Pay frequency must be annual, monthly, biweekly, or weekly" unless %w[annual monthly biweekly weekly].include?(@pay_frequency)
    end

    def pay_periods
      case @pay_frequency
      when "annual" then 1
      when "monthly" then 12
      when "biweekly" then 26
      when "weekly" then 52
      end
    end

    def calculate_deductions
      case @country
      when "us" then us_deductions
      when "uk" then uk_deductions
      when "ca" then ca_deductions
      when "au" then au_deductions
      end
    end

    def us_deductions
      federal_tax = us_federal_tax
      social_security = [ @gross_salary * 0.062, 168_600 * 0.062 ].min
      medicare = @gross_salary * 0.0145
      medicare += (@gross_salary - 200_000) * 0.009 if @gross_salary > 200_000

      {
        federal_tax: federal_tax,
        social_security: social_security,
        medicare: medicare
      }
    end

    def us_federal_tax
      # 2024 simplified brackets for single
      brackets = if @filing_status == "married"
        [ [ 23_200, 0 ], [ 23_200, 0.10 ], [ 94_300 - 23_200, 0.12 ],
         [ 201_050 - 94_300, 0.22 ], [ 383_900 - 201_050, 0.24 ],
         [ 487_450 - 383_900, 0.32 ], [ 731_200 - 487_450, 0.35 ],
         [ Float::INFINITY, 0.37 ] ]
      else
        [ [ 11_600, 0 ], [ 11_600, 0.10 ], [ 47_150 - 11_600, 0.12 ],
         [ 100_525 - 47_150, 0.22 ], [ 191_950 - 100_525, 0.24 ],
         [ 243_725 - 191_950, 0.32 ], [ 609_350 - 243_725, 0.35 ],
         [ Float::INFINITY, 0.37 ] ]
      end

      tax = 0.0
      remaining = @gross_salary

      brackets.each do |width, rate|
        taxable = [ remaining, width ].min
        tax += taxable * rate
        remaining -= taxable
        break if remaining <= 0
      end

      tax
    end

    def uk_deductions
      # UK 2024/25 simplified
      income_tax = uk_income_tax
      national_insurance = uk_national_insurance

      {
        income_tax: income_tax,
        national_insurance: national_insurance
      }
    end

    def uk_income_tax
      personal_allowance = 12_570
      taxable = [ @gross_salary - personal_allowance, 0 ].max

      brackets = [ [ 37_700, 0.20 ], [ 99_730, 0.40 ], [ Float::INFINITY, 0.45 ] ]
      tax = 0.0
      remaining = taxable

      brackets.each do |width, rate|
        amount = [ remaining, width ].min
        tax += amount * rate
        remaining -= amount
        break if remaining <= 0
      end

      tax
    end

    def uk_national_insurance
      # Class 1 employee NI 2024/25
      weekly = @gross_salary / 52.0
      threshold = 242.0 # weekly primary threshold
      upper = 967.0 # weekly upper earnings limit

      if weekly <= threshold
        0.0
      elsif weekly <= upper
        (weekly - threshold) * 0.08 * 52
      else
        ((upper - threshold) * 0.08 + (weekly - upper) * 0.02) * 52
      end
    end

    def ca_deductions
      federal_tax = ca_federal_tax
      cpp = [ (@gross_salary - 3_500) * 0.0595, 3_867.50 ].min
      cpp = [ cpp, 0 ].max
      ei = [ @gross_salary * 0.0166, 1_049.12 ].min

      {
        federal_tax: federal_tax,
        cpp: cpp,
        ei: ei
      }
    end

    def ca_federal_tax
      personal_amount = 15_705
      taxable = [ @gross_salary - personal_amount, 0 ].max

      brackets = [ [ 55_867, 0.15 ], [ 111_733 - 55_867, 0.205 ],
                  [ 154_906 - 111_733, 0.26 ], [ 220_000 - 154_906, 0.29 ],
                  [ Float::INFINITY, 0.33 ] ]
      tax = 0.0
      remaining = taxable

      brackets.each do |width, rate|
        amount = [ remaining, width ].min
        tax += amount * rate
        remaining -= amount
        break if remaining <= 0
      end

      tax
    end

    def au_deductions
      income_tax = au_income_tax
      medicare_levy = @gross_salary * 0.02

      {
        income_tax: income_tax,
        medicare_levy: medicare_levy
      }
    end

    def au_income_tax
      # Australia 2024/25
      brackets = [ [ 18_200, 0 ], [ 45_000 - 18_200, 0.16 ],
                  [ 135_000 - 45_000, 0.30 ], [ 190_000 - 135_000, 0.37 ],
                  [ Float::INFINITY, 0.45 ] ]
      tax = 0.0
      remaining = @gross_salary

      brackets.each do |width, rate|
        amount = [ remaining, width ].min
        tax += amount * rate
        remaining -= amount
        break if remaining <= 0
      end

      tax
    end
  end
end
