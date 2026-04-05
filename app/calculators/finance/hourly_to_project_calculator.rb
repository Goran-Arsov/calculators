# frozen_string_literal: true

module Finance
  class HourlyToProjectCalculator
    attr_reader :errors

    def initialize(hourly_rate:, estimated_hours:, expenses: 0, tax_rate: 0)
      @hourly_rate = hourly_rate.to_f
      @estimated_hours = estimated_hours.to_f
      @expenses = expenses.to_f
      @tax_rate = tax_rate.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      labor_cost = @hourly_rate * @estimated_hours
      subtotal = labor_cost + @expenses
      tax_amount = subtotal * (@tax_rate / 100.0)
      project_total = subtotal + tax_amount

      effective_hourly_rate = project_total / @estimated_hours
      after_tax_income = labor_cost - (labor_cost * @tax_rate / 100.0)

      {
        valid: true,
        labor_cost: labor_cost.round(2),
        expenses: @expenses.round(2),
        subtotal: subtotal.round(2),
        tax_amount: tax_amount.round(2),
        project_total: project_total.round(2),
        effective_hourly_rate: effective_hourly_rate.round(2),
        after_tax_income: after_tax_income.round(2)
      }
    end

    private

    def validate!
      @errors << "Hourly rate must be greater than zero" unless @hourly_rate.positive?
      @errors << "Estimated hours must be greater than zero" unless @estimated_hours.positive?
      @errors << "Expenses cannot be negative" if @expenses.negative?
      @errors << "Tax rate cannot be negative" if @tax_rate.negative?
      @errors << "Tax rate cannot exceed 100%" if @tax_rate > 100
    end
  end
end
