# frozen_string_literal: true

module Finance
  class PensionCalculator
    attr_reader :errors

    def initialize(current_age:, retirement_age:, current_savings:, monthly_contribution:,
                   annual_return_rate:, annual_inflation_rate:, years_in_retirement:)
      @current_age = current_age.to_i
      @retirement_age = retirement_age.to_i
      @current_savings = current_savings.to_f
      @monthly_contribution = monthly_contribution.to_f
      @annual_return_rate = annual_return_rate.to_f / 100.0
      @annual_inflation_rate = annual_inflation_rate.to_f / 100.0
      @years_in_retirement = years_in_retirement.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      years_to_retire = @retirement_age - @current_age
      months_to_retire = years_to_retire * 12
      monthly_return = @annual_return_rate / 12.0

      # Nominal pot at retirement (future value of savings + contributions)
      if monthly_return.zero?
        nominal_pot = @current_savings + @monthly_contribution * months_to_retire
      else
        nominal_pot = @current_savings * (1 + monthly_return)**months_to_retire +
                      @monthly_contribution * ((1 + monthly_return)**months_to_retire - 1) / monthly_return
      end

      # Inflation discount factor for years until retirement
      inflation_factor = (1 + @annual_inflation_rate)**years_to_retire
      real_pot = nominal_pot / inflation_factor

      # Nominal monthly income during retirement (annuity payment)
      retirement_months = @years_in_retirement * 12
      nominal_monthly_income = annuity_payment(nominal_pot, monthly_return, retirement_months)

      # Real monthly income in today's money
      real_monthly_income = nominal_monthly_income / inflation_factor

      total_contributions = @current_savings + @monthly_contribution * months_to_retire

      {
        valid: true,
        years_to_retire: years_to_retire,
        nominal_pot: nominal_pot.round(2),
        real_pot: real_pot.round(2),
        total_contributions: total_contributions.round(2),
        nominal_monthly_income: nominal_monthly_income.round(2),
        real_monthly_income: real_monthly_income.round(2)
      }
    end

    private

    def annuity_payment(principal, monthly_rate, num_months)
      return 0.0 if num_months <= 0
      return principal / num_months if monthly_rate.zero?

      principal * monthly_rate / (1 - (1 + monthly_rate)**-num_months)
    end

    def validate!
      @errors << "Current age must be positive" unless @current_age > 0
      @errors << "Retirement age must be greater than current age" unless @retirement_age > @current_age
      @errors << "Current savings cannot be negative" if @current_savings < 0
      @errors << "Monthly contribution cannot be negative" if @monthly_contribution < 0
      @errors << "Annual return rate cannot be negative" if @annual_return_rate < 0
      @errors << "Inflation rate cannot be negative" if @annual_inflation_rate < 0
      @errors << "Years in retirement must be positive" unless @years_in_retirement > 0
    end
  end
end
