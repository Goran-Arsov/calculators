# frozen_string_literal: true

module Geography
  class MapScaleCalculator
    attr_reader :errors

    UNITS = %w[cm mm in].freeze

    def initialize(scale_ratio:, map_distance:, map_unit: "cm")
      @scale_ratio = scale_ratio.to_f
      @map_distance = map_distance.to_f
      @map_unit = map_unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      distance_in_meters = map_to_meters(@map_distance, @map_unit) * @scale_ratio

      {
        valid: true,
        real_meters: distance_in_meters.round(3),
        real_km: (distance_in_meters / 1000.0).round(4),
        real_miles: (distance_in_meters / 1609.344).round(4),
        real_feet: (distance_in_meters * 3.28084).round(3),
        real_yards: (distance_in_meters * 1.09361).round(3)
      }
    end

    private

    def map_to_meters(value, unit)
      case unit
      when "cm" then value / 100.0
      when "mm" then value / 1000.0
      when "in" then value * 0.0254
      else 0.0
      end
    end

    def validate!
      @errors << "Scale ratio must be greater than zero" unless @scale_ratio.positive?
      @errors << "Map distance must be greater than zero" unless @map_distance.positive?
      @errors << "Map unit must be cm, mm, or in" unless UNITS.include?(@map_unit)
    end
  end
end
