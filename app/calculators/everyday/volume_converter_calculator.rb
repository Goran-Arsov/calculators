# frozen_string_literal: true

module Everyday
  class VolumeConverterCalculator
    attr_reader :errors

    UNITS = %w[cubic_meter cubic_foot cubic_inch cubic_yard liter gallon_us gallon_uk].freeze

    # Conversion factors to cubic meters
    TO_CUBIC_METERS = {
      "cubic_meter" => 1.0,
      "cubic_foot"  => 0.0283168,
      "cubic_inch"  => 0.0000163871,
      "cubic_yard"  => 0.764555,
      "liter"       => 0.001,
      "gallon_us"   => 0.00378541,
      "gallon_uk"   => 0.00454609
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cubic_meters = @value * TO_CUBIC_METERS[@from_unit]

      conversions = UNITS.each_with_object({}) do |unit, hash|
        hash[unit.to_sym] = (cubic_meters / TO_CUBIC_METERS[unit]).round(6)
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
