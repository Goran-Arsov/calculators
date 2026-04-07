# frozen_string_literal: true

module Everyday
  class TemperatureConverterCalculator
    attr_reader :errors

    UNITS = %w[celsius fahrenheit kelvin].freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      celsius = to_celsius(@value, @from_unit)

      {
        valid: true,
        celsius: celsius.round(4),
        fahrenheit: (celsius * 9.0 / 5.0 + 32).round(4),
        kelvin: (celsius + 273.15).round(4),
        from_unit: @from_unit,
        original_value: @value
      }
    end

    private

    def to_celsius(value, unit)
      case unit
      when "celsius"
        value
      when "fahrenheit"
        (value - 32) * 5.0 / 9.0
      when "kelvin"
        value - 273.15
      end
    end

    def validate!
      @errors << "Unknown unit: #{@from_unit}. Valid: #{UNITS.join(', ')}" unless UNITS.include?(@from_unit)
    end
  end
end
