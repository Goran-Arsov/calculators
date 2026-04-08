# frozen_string_literal: true

module Everyday
  class CupConverterCalculator
    attr_reader :errors

    UNITS = %w[us_cup metric_cup imperial_cup ml l fl_oz us_tbsp us_tsp].freeze

    # Conversion factors to milliliters
    TO_ML = {
      "us_cup"       => 236.588,
      "metric_cup"   => 250.0,
      "imperial_cup" => 284.131,
      "ml"           => 1.0,
      "l"            => 1000.0,
      "fl_oz"        => 29.5735,
      "us_tbsp"      => 14.7868,
      "us_tsp"       => 4.92892
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ml = @value * TO_ML[@from_unit]

      conversions = UNITS.each_with_object({}) do |unit, hash|
        hash[unit.to_sym] = (ml / TO_ML[unit]).round(6)
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
