# frozen_string_literal: true

module Finance
  class SavingsPerMonthCalculator
    attr_reader :errors

    def initialize(savings_goal:, months:, current_savings: nil, annual_rate: nil)
      @savings_goal = savings_goal.to_f
      @months = months.to_i
      @current_savings = current_savings.nil? || current_savings.to_s.strip.empty? ? 0.0 : current_savings.to_f
      @annual_rate = annual_rate.nil? || annual_rate.to_s.strip.empty? ? nil : annual_rate.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      remaining = @savings_goal - @current_savings

      if @annual_rate && @annual_rate > 0
        monthly_rate = @annual_rate / 100.0 / 12.0

        # Future value of current savings after n months
        fv_current = @current_savings * ((1 + monthly_rate) ** @months)
        amount_needed = @savings_goal - fv_current

        if amount_needed <= 0
          monthly_savings = 0.0
        else
          # PMT formula: amount_needed = pmt * ((1+r)^n - 1) / r
          monthly_savings = amount_needed * monthly_rate / (((1 + monthly_rate) ** @months) - 1)
        end

        total_contributions = monthly_savings * @months
        total_interest = @savings_goal - @current_savings - total_contributions

        result = {
          valid: true,
          monthly_savings: monthly_savings.round(4),
          savings_goal: @savings_goal.round(2),
          current_savings: @current_savings.round(2),
          remaining: remaining.round(2),
          months: @months,
          annual_rate: @annual_rate.round(4),
          total_contributions: total_contributions.round(2),
          total_interest: total_interest.round(2)
        }
      else
        monthly_savings = remaining / @months

        result = {
          valid: true,
          monthly_savings: monthly_savings.round(4),
          savings_goal: @savings_goal.round(2),
          current_savings: @current_savings.round(2),
          remaining: remaining.round(2),
          months: @months,
          total_contributions: remaining.round(2),
          total_interest: 0.0
        }
      end

      result
    end

    private

    def validate!
      @errors << "Savings goal must be positive" unless @savings_goal > 0
      @errors << "Months must be positive" unless @months > 0
      @errors << "Current savings cannot be negative" if @current_savings < 0
      @errors << "Current savings cannot exceed savings goal" if @current_savings >= @savings_goal
      @errors << "Annual interest rate cannot be negative" if @annual_rate && @annual_rate < 0
    end
  end
end
