# frozen_string_literal: true

module Gardening
  class GrowingDegreeDaysCalculator
    attr_reader :errors

    UNITS = %w[fahrenheit celsius].freeze
    DEFAULT_BASE_F = 50.0
    DEFAULT_BASE_C = 10.0

    def initialize(tmax:, tmin:, base: nil, unit: "fahrenheit")
      @tmax = tmax.to_f
      @tmin = tmin.to_f
      @unit = unit.to_s
      @base = base.nil? || base.to_s == "" ? nil : base.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base = @base || (@unit == "celsius" ? DEFAULT_BASE_C : DEFAULT_BASE_F)
      average = (@tmax + @tmin) / 2.0
      gdd = [ average - base, 0.0 ].max

      {
        valid: true,
        average_temp: average.round(2),
        base_temp: base.round(2),
        gdd: gdd.round(2),
        unit: @unit
      }
    end

    private

    def validate!
      @errors << "Unit must be one of: #{UNITS.join(', ')}" unless UNITS.include?(@unit)
      @errors << "Max temperature must be greater than or equal to min" if @tmax < @tmin
    end
  end
end
