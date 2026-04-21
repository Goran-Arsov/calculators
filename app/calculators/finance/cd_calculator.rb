# frozen_string_literal: true

module Finance
  class CdCalculator
    include Finance::InflationAdjustment

    attr_reader :errors

    VALID_COMPOUNDING = %w[daily monthly quarterly annually].freeze

    COMPOUNDING_PERIODS = {
      "daily"     => 365,
      "monthly"   => 12,
      "quarterly" => 4,
      "annually"  => 1
    }.freeze

    def initialize(principal:, apy:, term_months:, compounding: "daily", annual_inflation_rate: nil)
      @principal = principal.to_f
      @apy = apy.to_f / 100.0
      @term_months = term_months.to_i
      @compounding = compounding.to_s.downcase.strip
      @annual_inflation_rate = annual_inflation_rate.nil? ? nil : annual_inflation_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      n = COMPOUNDING_PERIODS[@compounding]
      t = @term_months / 12.0

      # APY is already the effective annual rate, so convert to nominal rate for compounding
      # APY = (1 + r/n)^n - 1, solving for r: r = n * ((1 + APY)^(1/n) - 1)
      nominal_rate = n * ((1 + @apy)**(1.0 / n) - 1)

      maturity_value = @principal * (1 + nominal_rate / n)**(n * t)
      interest_earned = maturity_value - @principal

      # Monthly interest breakdown
      monthly_breakdown = []
      @term_months.times do |i|
        month_t = (i + 1) / 12.0
        value_at_month = @principal * (1 + nominal_rate / n)**(n * month_t)
        monthly_breakdown << {
          month: i + 1,
          value: value_at_month.round(2),
          interest: (value_at_month - @principal).round(2)
        }
      end

      apy_decimal = @apy * 100

      result = {
        valid: true,
        principal: @principal.round(2),
        maturity_value: maturity_value.round(2),
        interest_earned: interest_earned.round(2),
        apy: apy_decimal.round(2),
        term_months: @term_months,
        compounding: @compounding,
        monthly_breakdown: monthly_breakdown
      }
      apply_inflation(result, years: t, nominal_keys: [ :maturity_value, :interest_earned ])
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "APY must be positive" unless @apy > 0
      @errors << "Term must be positive" unless @term_months > 0
      @errors << "Invalid compounding frequency" unless VALID_COMPOUNDING.include?(@compounding)
      @errors << inflation_rate_error if inflation_rate_error
    end
  end
end
