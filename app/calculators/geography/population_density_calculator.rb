# frozen_string_literal: true

module Geography
  class PopulationDensityCalculator
    attr_reader :errors

    AREA_UNITS = %w[km2 mi2 ha acre m2].freeze

    def initialize(population:, area:, area_unit: "km2")
      @population = population.to_f
      @area = area.to_f
      @area_unit = area_unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_km2 = convert_to_km2(@area, @area_unit)
      return { valid: false, errors: [ "Area converts to zero — enter a larger area" ] } if area_km2.zero?

      density_per_km2 = @population / area_km2
      area_mi2 = area_km2 / 2.58999
      density_per_mi2 = @population / area_mi2

      {
        valid: true,
        density_per_km2: density_per_km2.round(3),
        density_per_mi2: density_per_mi2.round(3),
        density_per_hectare: (density_per_km2 / 100.0).round(4),
        density_per_acre: (density_per_mi2 / 640.0).round(4),
        area_km2: area_km2.round(4),
        area_mi2: area_mi2.round(4),
        classification: classify(density_per_km2)
      }
    end

    private

    def convert_to_km2(value, unit)
      case unit
      when "km2" then value
      when "mi2" then value * 2.58999
      when "ha" then value / 100.0
      when "acre" then value * 0.00404686
      when "m2" then value / 1_000_000.0
      else 0.0
      end
    end

    def classify(density)
      case density
      when 0...10 then "Very sparse (wilderness/rural)"
      when 10...100 then "Sparse (rural)"
      when 100...500 then "Moderate (suburban)"
      when 500...2_000 then "Dense (urban)"
      when 2_000...10_000 then "Very dense (inner city)"
      else "Hyperdense (megacity core)"
      end
    end

    def validate!
      @errors << "Population must be greater than zero" unless @population.positive?
      @errors << "Area must be greater than zero" unless @area.positive?
      @errors << "Area unit must be one of: km2, mi2, ha, acre, m2" unless AREA_UNITS.include?(@area_unit)
    end
  end
end
