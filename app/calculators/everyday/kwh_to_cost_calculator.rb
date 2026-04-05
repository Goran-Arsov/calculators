# frozen_string_literal: true

module Everyday
  class KwhToCostCalculator
    attr_reader :errors

    DAYS_PER_MONTH = 30.0
    DAYS_PER_YEAR = 365.0

    def initialize(kwh_usage:, rate_per_kwh:, period: "daily")
      @kwh_usage = kwh_usage.to_f
      @rate_per_kwh = rate_per_kwh.to_f
      @period = period.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      daily_kwh = calculate_daily_kwh

      daily_cost = daily_kwh * @rate_per_kwh
      monthly_cost = daily_cost * DAYS_PER_MONTH
      yearly_cost = daily_cost * DAYS_PER_YEAR

      {
        valid: true,
        daily_kwh: daily_kwh.round(2),
        daily_cost: daily_cost.round(2),
        monthly_cost: monthly_cost.round(2),
        yearly_cost: yearly_cost.round(2)
      }
    end

    private

    def calculate_daily_kwh
      case @period
      when "daily"   then @kwh_usage
      when "monthly" then @kwh_usage / DAYS_PER_MONTH
      when "yearly"  then @kwh_usage / DAYS_PER_YEAR
      else @kwh_usage
      end
    end

    def validate!
      @errors << "kWh usage must be greater than zero" unless @kwh_usage.positive?
      @errors << "Rate per kWh must be greater than zero" unless @rate_per_kwh.positive?
      @errors << "Invalid period" unless %w[daily monthly yearly].include?(@period)
    end
  end
end
