# frozen_string_literal: true

module Gardening
  class TreeAgeCalculator
    attr_reader :errors

    # International Society of Arboriculture growth factors: years per inch of diameter (DBH).
    GROWTH_FACTORS = {
      "red_oak" => 4.0,
      "white_oak" => 5.0,
      "red_maple" => 4.5,
      "sugar_maple" => 5.5,
      "silver_maple" => 3.0,
      "white_pine" => 5.0,
      "scotch_pine" => 3.5,
      "cottonwood" => 2.0,
      "dogwood" => 7.0,
      "white_birch" => 5.0,
      "walnut" => 4.5,
      "ash" => 4.0,
      "american_beech" => 6.0,
      "apple" => 2.0,
      "basswood" => 3.0,
      "bradford_pear" => 3.0,
      "shagbark_hickory" => 7.5,
      "tulip_poplar" => 3.0,
      "redwood" => 5.0
    }.freeze

    def initialize(circumference_in:, species:)
      @circumference_in = circumference_in.to_f
      @species = species.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      diameter = @circumference_in / Math::PI
      factor = GROWTH_FACTORS[@species]
      age = diameter * factor

      {
        valid: true,
        diameter_in: diameter.round(2),
        growth_factor: factor,
        age_years: age.round(0)
      }
    end

    private

    def validate!
      @errors << "Circumference must be greater than zero" unless @circumference_in.positive?
      unless GROWTH_FACTORS.key?(@species)
        @errors << "Species must be one of the supported types"
      end
    end
  end
end
