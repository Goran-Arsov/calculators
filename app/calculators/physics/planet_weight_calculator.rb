# frozen_string_literal: true

module Physics
  class PlanetWeightCalculator
    attr_reader :errors

    PLANETS = {
      "Mercury" => 0.378,
      "Venus"   => 0.907,
      "Mars"    => 0.377,
      "Jupiter" => 2.36,
      "Saturn"  => 0.916,
      "Uranus"  => 0.889,
      "Neptune" => 1.12,
      "Moon"    => 0.1654,
      "Pluto"   => 0.071
    }.freeze

    def initialize(earth_weight:)
      @earth_weight = earth_weight.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weights = PLANETS.each_with_object({}) do |(planet, ratio), hash|
        hash[planet] = (@earth_weight * ratio).round(2)
      end

      weights.merge(valid: true)
    end

    private

    def validate!
      @errors << "Earth weight must be greater than zero" unless @earth_weight.positive?
    end
  end
end
