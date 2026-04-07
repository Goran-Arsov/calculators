# frozen_string_literal: true

module Everyday
  class LengthConverterCalculator
    attr_reader :errors

    UNITS = %w[mm cm m km inch foot yard mile].freeze

    # Conversion factors to meters
    TO_METERS = {
      "mm"   => 0.001,
      "cm"   => 0.01,
      "m"    => 1.0,
      "km"   => 1000.0,
      "inch" => 0.0254,
      "foot" => 0.3048,
      "yard" => 0.9144,
      "mile" => 1609.344
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      meters = @value * TO_METERS[@from_unit]

      conversions = UNITS.each_with_object({}) do |unit, hash|
        hash[unit.to_sym] = (meters / TO_METERS[unit]).round(6)
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
