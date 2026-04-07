# frozen_string_literal: true

module Everyday
  class SpeedConverterCalculator
    attr_reader :errors

    UNITS = %w[m/s km/h mph knots ft/s].freeze

    # Conversion factors to m/s
    TO_MPS = {
      "m/s"   => 1.0,
      "km/h"  => 1.0 / 3.6,
      "mph"   => 0.44704,
      "knots" => 0.514444,
      "ft/s"  => 0.3048
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      mps = @value * TO_MPS[@from_unit]

      conversions = UNITS.each_with_object({}) do |unit, hash|
        hash[unit.to_sym] = (mps / TO_MPS[unit]).round(6)
      end

      {
        valid: true,
        conversions: conversions,
        from_unit: @from_unit,
        original_value: @value
      }
    end

    private

    def validate!
      @errors << "Value must be a number" if @value.nil?
      @errors << "Unknown unit: #{@from_unit}. Valid: #{UNITS.join(', ')}" unless UNITS.include?(@from_unit)
    end
  end
end
