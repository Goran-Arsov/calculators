# frozen_string_literal: true

module Everyday
  class WeightConverterCalculator
    attr_reader :errors

    UNITS = %w[mg g kg tonne ounce pound stone].freeze

    # Conversion factors to grams
    TO_GRAMS = {
      "mg"    => 0.001,
      "g"     => 1.0,
      "kg"    => 1000.0,
      "tonne" => 1_000_000.0,
      "ounce" => 28.3495,
      "pound" => 453.592,
      "stone" => 6350.29
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      grams = @value * TO_GRAMS[@from_unit]

      conversions = UNITS.each_with_object({}) do |unit, hash|
        hash[unit.to_sym] = (grams / TO_GRAMS[unit]).round(6)
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
