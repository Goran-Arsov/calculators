# frozen_string_literal: true

module Finance
  class SolarSavingsCalculator
    attr_reader :errors

    def initialize(system_size_kw:, electricity_rate:, sun_hours_per_day:, system_cost:)
      @system_size_kw = system_size_kw.to_f
      @electricity_rate = electricity_rate.to_f
      @sun_hours_per_day = sun_hours_per_day.to_f
      @system_cost = system_cost.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      annual_production_kwh = @system_size_kw * @sun_hours_per_day * 365
      annual_savings = annual_production_kwh * @electricity_rate
      payback_years = annual_savings > 0 ? @system_cost / annual_savings : Float::INFINITY
      savings_25_years = (annual_savings * 25) - @system_cost

      {
        valid: true,
        annual_production_kwh: annual_production_kwh.round(4),
        annual_savings: annual_savings.round(4),
        payback_years: payback_years.round(4),
        savings_25_years: savings_25_years.round(4),
        system_size_kw: @system_size_kw.round(4),
        electricity_rate: @electricity_rate.round(4),
        sun_hours_per_day: @sun_hours_per_day.round(4),
        system_cost: @system_cost.round(4)
      }
    end

    private

    def validate!
      @errors << "System size must be positive" unless @system_size_kw > 0
      @errors << "Electricity rate must be positive" unless @electricity_rate > 0
      @errors << "Sun hours per day must be positive" unless @sun_hours_per_day > 0
      @errors << "Sun hours per day cannot exceed 24" if @sun_hours_per_day > 24
      @errors << "System cost must be positive" unless @system_cost > 0
    end
  end
end
