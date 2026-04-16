# frozen_string_literal: true

module Finance
  class SideHustleCalculator
    attr_reader :errors

    SE_TAX_FACTOR = 0.9235   # Only 92.35% of net profit is subject to SE tax
    SE_TAX_RATE   = 0.153    # 12.4% Social Security + 2.9% Medicare

    def initialize(gross_revenue:, business_expenses:, tax_rate_percent:, hours_per_week:)
      @gross_revenue = gross_revenue.to_f
      @business_expenses = business_expenses.to_f
      @tax_rate_percent = tax_rate_percent.to_f
      @hours_per_week = hours_per_week.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      net_profit = @gross_revenue - @business_expenses
      se_taxable = net_profit * SE_TAX_FACTOR
      self_employment_tax = [ se_taxable * SE_TAX_RATE, 0 ].max
      income_tax = [ net_profit * (@tax_rate_percent / 100.0), 0 ].max
      annual_take_home = net_profit - self_employment_tax - income_tax
      monthly_take_home = annual_take_home / 12.0
      annual_hours = @hours_per_week * 52
      effective_hourly_rate = annual_hours > 0 ? annual_take_home / annual_hours : 0.0

      {
        valid: true,
        gross_revenue: @gross_revenue.round(2),
        business_expenses: @business_expenses.round(2),
        net_profit: net_profit.round(2),
        self_employment_tax: self_employment_tax.round(2),
        income_tax_estimate: income_tax.round(2),
        annual_take_home: annual_take_home.round(2),
        monthly_take_home: monthly_take_home.round(2),
        effective_hourly_rate: effective_hourly_rate.round(2),
        hours_per_week: @hours_per_week.round(1)
      }
    end

    private

    def validate!
      @errors << "Gross revenue cannot be negative" if @gross_revenue < 0
      @errors << "Business expenses cannot be negative" if @business_expenses < 0
      @errors << "Tax rate must be between 0 and 100" unless @tax_rate_percent >= 0 && @tax_rate_percent <= 100
      @errors << "Hours per week must be positive" unless @hours_per_week > 0
      @errors << "Hours per week cannot exceed 168" if @hours_per_week > 168
    end
  end
end
