# frozen_string_literal: true

module Finance
  class FreelanceRateCalculator
    attr_reader :errors

    def initialize(target_annual_income:, annual_expenses:, billable_hours_per_week:, weeks_vacation:, tax_rate:, profit_margin: 10)
      @target_annual_income = target_annual_income.to_f
      @annual_expenses = annual_expenses.to_f
      @billable_hours_per_week = billable_hours_per_week.to_f
      @weeks_vacation = weeks_vacation.to_i
      @tax_rate = tax_rate.to_f / 100.0
      @profit_margin = profit_margin.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      working_weeks = 52 - @weeks_vacation
      annual_billable_hours = @billable_hours_per_week * working_weeks

      # Total needed: income + expenses + taxes + profit margin
      pre_tax_income = @target_annual_income / (1 - @tax_rate)
      total_annual_needed = pre_tax_income + @annual_expenses
      total_with_margin = total_annual_needed * (1 + @profit_margin)

      hourly_rate = total_with_margin / annual_billable_hours
      daily_rate = hourly_rate * 8
      weekly_rate = hourly_rate * @billable_hours_per_week
      monthly_rate = total_with_margin / 12.0

      estimated_taxes = pre_tax_income * @tax_rate

      {
        valid: true,
        hourly_rate: hourly_rate.round(2),
        daily_rate: daily_rate.round(2),
        weekly_rate: weekly_rate.round(2),
        monthly_rate: monthly_rate.round(2),
        annual_revenue: total_with_margin.round(2),
        annual_billable_hours: annual_billable_hours.round(0),
        working_weeks: working_weeks,
        estimated_taxes: estimated_taxes.round(2),
        effective_hourly_income: (@target_annual_income / annual_billable_hours).round(2)
      }
    end

    private

    def validate!
      @errors << "Target annual income must be positive" unless @target_annual_income > 0
      @errors << "Annual expenses cannot be negative" if @annual_expenses < 0
      @errors << "Billable hours per week must be positive" unless @billable_hours_per_week > 0
      @errors << "Vacation weeks must be between 0 and 51" unless @weeks_vacation >= 0 && @weeks_vacation < 52
      @errors << "Tax rate must be between 0 and 99" unless @tax_rate >= 0 && @tax_rate < 1.0
      @errors << "Profit margin cannot be negative" if @profit_margin < 0
    end
  end
end
