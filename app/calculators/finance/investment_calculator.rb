# frozen_string_literal: true

module Finance
  class InvestmentCalculator
    include Finance::InflationAdjustment

    attr_reader :errors

    def initialize(initial:, monthly_contribution:, annual_rate:, years:, annual_inflation_rate: nil)
      @initial = initial.to_f
      @monthly_contribution = monthly_contribution.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @annual_inflation_rate = annual_inflation_rate.nil? ? nil : annual_inflation_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      num_months = @years * 12

      if monthly_rate.zero?
        future_value = @initial + @monthly_contribution * num_months
      else
        future_value = @initial * (1 + monthly_rate)**num_months +
                       @monthly_contribution * ((1 + monthly_rate)**num_months - 1) / monthly_rate
      end

      total_contributions = @initial + @monthly_contribution * num_months
      total_growth = future_value - total_contributions

      result = {
        valid: true,
        future_value: future_value.round(2),
        total_contributions: total_contributions.round(2),
        total_growth: total_growth.round(2)
      }
      apply_inflation(result, years: @years, nominal_keys: [ :future_value, :total_growth ])
    end

    private

    def validate!
      @errors << "Initial investment cannot be negative" if @initial < 0
      @errors << "Monthly contribution cannot be negative" if @monthly_contribution < 0
      @errors << "Time period must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Initial investment or monthly contribution must be positive" if @initial.zero? && @monthly_contribution.zero?
      @errors << inflation_rate_error if inflation_rate_error
    end
  end
end
