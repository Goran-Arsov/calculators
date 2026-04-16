# frozen_string_literal: true

module Health
  class AlcoholBurnoffCalculator
    attr_reader :errors

    # Widmark gender distribution factors
    GENDER_FACTOR = {
      "male" => 0.68,
      "female" => 0.55
    }.freeze

    # One standard drink contains 14 grams of pure alcohol (US standard)
    ALCOHOL_GRAMS_PER_DRINK = 14.0

    # BAC elimination rate per hour
    ELIMINATION_RATE = 0.015

    def initialize(num_standard_drinks:, weight_kg:, gender:, hours_since_first_drink:)
      @drinks = num_standard_drinks.to_f
      @weight_kg = weight_kg.to_f
      @gender = gender.to_s
      @hours = hours_since_first_drink.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      factor = GENDER_FACTOR[@gender]
      alcohol_grams = @drinks * ALCOHOL_GRAMS_PER_DRINK
      weight_grams = @weight_kg * 1000.0

      # Widmark formula: BAC = (alcohol_grams / (weight_grams × gender_factor)) × 100
      peak_bac = (alcohol_grams / (weight_grams * factor)) * 100.0
      current_bac = [ peak_bac - (ELIMINATION_RATE * @hours), 0.0 ].max
      hours_until_sober = current_bac > 0 ? (current_bac / ELIMINATION_RATE) : 0.0

      {
        valid: true,
        peak_bac: peak_bac.round(4),
        current_bac: current_bac.round(4),
        hours_until_sober: hours_until_sober.round(1),
        bac_level_description: describe_level(current_bac)
      }
    end

    private

    def describe_level(bac)
      case bac
      when 0.0...0.02 then "sober"
      when 0.02...0.06 then "mild"
      when 0.06...0.15 then "moderate"
      else "severe"
      end
    end

    def validate!
      @errors << "Number of drinks must be positive" unless @drinks > 0
      @errors << "Weight must be positive" unless @weight_kg > 0
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Hours must be zero or positive" unless @hours >= 0
      @errors << "Number of drinks cannot exceed 50" if @drinks > 50
      @errors << "Weight cannot exceed 300 kg" if @weight_kg > 300
      @errors << "Hours cannot exceed 48" if @hours > 48
    end
  end
end
