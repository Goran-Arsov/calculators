module Finance
  class RetirementCalculator
    attr_reader :errors

    def initialize(current_age:, retirement_age:, current_savings:, monthly_contribution:, annual_rate:)
      @current_age = current_age.to_i
      @retirement_age = retirement_age.to_i
      @current_savings = current_savings.to_f
      @monthly_contribution = monthly_contribution.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      years_to_retire = @retirement_age - @current_age
      monthly_rate = @annual_rate / 12.0
      num_months = years_to_retire * 12

      if monthly_rate.zero?
        projected_savings = @current_savings + @monthly_contribution * num_months
      else
        projected_savings = @current_savings * (1 + monthly_rate)**num_months +
                            @monthly_contribution * ((1 + monthly_rate)**num_months - 1) / monthly_rate
      end

      # Estimate 25-year retirement, 4% withdrawal rate
      monthly_retirement_income = projected_savings * 0.04 / 12.0

      {
        valid: true,
        projected_savings: projected_savings.round(2),
        monthly_retirement_income: monthly_retirement_income.round(2),
        years_to_retire: years_to_retire,
        total_contributions: (@current_savings + @monthly_contribution * num_months).round(2)
      }
    end

    private

    def validate!
      @errors << "Current age must be positive" unless @current_age > 0
      @errors << "Retirement age must be greater than current age" unless @retirement_age > @current_age
      @errors << "Current savings cannot be negative" if @current_savings < 0
      @errors << "Monthly contribution cannot be negative" if @monthly_contribution < 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
