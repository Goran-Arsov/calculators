module Finance
  class SavingsGoalCalculator
    attr_reader :errors

    def initialize(goal:, years:, annual_rate:, current_savings: 0)
      @goal = goal.to_f
      @years = years.to_i
      @annual_rate = annual_rate.to_f / 100.0
      @current_savings = current_savings.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      num_months = @years * 12

      if monthly_rate.zero?
        future_current = @current_savings
        monthly_savings = ((@goal - future_current) / num_months)
      else
        future_current = @current_savings * (1 + monthly_rate)**num_months
        remaining = @goal - future_current
        monthly_savings = remaining * monthly_rate / ((1 + monthly_rate)**num_months - 1)
      end

      total_contributions = monthly_savings * num_months + @current_savings
      total_interest = @goal - total_contributions

      {
        valid: true,
        monthly_savings: [ monthly_savings.round(2), 0 ].max,
        total_contributions: total_contributions.round(2),
        total_interest: total_interest.round(2),
        goal: @goal.round(2)
      }
    end

    private

    def validate!
      @errors << "Goal amount must be positive" unless @goal > 0
      @errors << "Time period must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Current savings cannot be negative" if @current_savings < 0
    end
  end
end
