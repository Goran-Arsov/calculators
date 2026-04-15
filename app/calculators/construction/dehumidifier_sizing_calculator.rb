# frozen_string_literal: true

module Construction
  class DehumidifierSizingCalculator
    attr_reader :errors

    # Dehumidifier pints-per-day sizing based on ENERGY STAR / AHAM guidance.
    # Pints per day at 65% RH (new ENERGY STAR test) by conditions:
    #   moderately damp  = musty smell in damp weather
    #   very damp        = wet spots on walls/floor
    #   wet              = sweating walls, seepage
    #   extremely wet    = standing water, wet floor
    #
    # Table values are pints/day for the given floor area × condition.
    TABLE = [
      # floor_sqft, moderately_damp, very_damp, wet, extremely_wet
      [ 500,   10, 12, 14, 16 ],
      [ 1000,  14, 17, 20, 23 ],
      [ 1500,  18, 22, 26, 30 ],
      [ 2000,  22, 27, 32, 37 ],
      [ 2500,  26, 32, 38, 44 ],
      [ 3000,  30, 36, 42, 50 ]
    ].freeze

    CONDITION_INDEX = {
      "moderate"   => 1,
      "very_damp"  => 2,
      "wet"        => 3,
      "extreme"    => 4
    }.freeze

    PINTS_TO_LITERS = 0.473176

    def initialize(floor_area_sqft:, condition: "very_damp")
      @floor_area = floor_area_sqft.to_f
      @condition = condition.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      idx = CONDITION_INDEX[@condition]
      pints = interpolate(idx)
      liters = pints * PINTS_TO_LITERS
      category = pints <= 20 ? "Small portable" : pints <= 30 ? "Medium portable" : pints <= 50 ? "Large portable" : "Whole-house"

      {
        valid: true,
        floor_area_sqft: @floor_area.round(0),
        condition: @condition,
        pints_per_day: pints.round(0),
        liters_per_day: liters.round(1),
        category: category
      }
    end

    private

    def validate!
      @errors << "Floor area must be greater than zero" unless @floor_area.positive?
      @errors << "Condition must be moderate, very_damp, wet, or extreme" unless CONDITION_INDEX.key?(@condition)
    end

    def interpolate(col)
      return TABLE.first[col] if @floor_area <= TABLE.first[0]
      return TABLE.last[col] if @floor_area >= TABLE.last[0]
      TABLE.each_cons(2) do |(a_sqft, *a_vals), (b_sqft, *b_vals)|
        if @floor_area.between?(a_sqft, b_sqft)
          a = a_vals[col - 1]
          b = b_vals[col - 1]
          return a + (b - a) * (@floor_area - a_sqft).to_f / (b_sqft - a_sqft)
        end
      end
      TABLE.last[col]
    end
  end
end
