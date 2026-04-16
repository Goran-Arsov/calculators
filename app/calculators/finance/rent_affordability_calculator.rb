# frozen_string_literal: true

module Finance
  class RentAffordabilityCalculator
    attr_reader :errors

    def initialize(monthly_income:, monthly_debts:, savings_goal_percent:)
      @monthly_income = monthly_income.to_f
      @monthly_debts = monthly_debts.to_f
      @savings_goal_percent = savings_goal_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # 30% rule
      max_rent_30_rule = @monthly_income * 0.30

      # 50/30/20 breakdown
      needs_budget = @monthly_income * 0.50
      wants_budget = @monthly_income * 0.30
      savings_budget = @monthly_income * 0.20

      # Adjusted max rent based on debts and savings goal
      savings_amount = @monthly_income * (@savings_goal_percent / 100.0)
      max_rent_adjusted = @monthly_income - @monthly_debts - savings_amount

      # Ensure adjusted rent is not negative
      max_rent_adjusted = 0.0 if max_rent_adjusted < 0

      {
        valid: true,
        max_rent_30_rule: max_rent_30_rule.round(2),
        max_rent_adjusted: max_rent_adjusted.round(2),
        needs_budget: needs_budget.round(2),
        wants_budget: wants_budget.round(2),
        savings_budget: savings_budget.round(2)
      }
    end

    private

    def validate!
      @errors << "Monthly income must be positive" unless @monthly_income > 0
      @errors << "Monthly debts cannot be negative" if @monthly_debts < 0
      @errors << "Savings goal percent cannot be negative" if @savings_goal_percent < 0
      @errors << "Savings goal percent cannot exceed 100" if @savings_goal_percent > 100
    end
  end
end
