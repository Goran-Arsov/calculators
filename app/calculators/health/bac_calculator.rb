# frozen_string_literal: true

module Health
  class BacCalculator
    attr_reader :errors

    # Widmark factors for alcohol distribution
    WIDMARK_FACTOR = {
      "male" => 0.68,
      "female" => 0.55
    }.freeze

    # Standard drink contains 14 grams of pure alcohol (US standard)
    ALCOHOL_GRAMS_PER_DRINK = 14.0

    # Alcohol is metabolized at approximately 0.015 BAC per hour
    METABOLISM_RATE = 0.015

    def initialize(drinks:, weight:, gender:, hours:, unit_system: "metric")
      @drinks = drinks.to_f
      @weight = weight.to_f
      @gender = gender.to_s
      @hours = hours.to_f
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_grams = weight_in_grams
      widmark = WIDMARK_FACTOR[@gender]

      # Widmark formula: BAC = (alcohol_grams / (body_weight_grams * widmark)) * 100 - (metabolism_rate * hours)
      alcohol_grams = @drinks * ALCOHOL_GRAMS_PER_DRINK
      raw_bac = (alcohol_grams / (weight_grams * widmark)) * 100
      bac = [ raw_bac - (METABOLISM_RATE * @hours), 0.0 ].max

      status = categorize(bac)
      hours_until_sober = bac > 0 ? (bac / METABOLISM_RATE) : 0.0

      {
        valid: true,
        bac: bac.round(4),
        status: status,
        hours_until_sober: hours_until_sober.round(1),
        alcohol_grams: alcohol_grams.round(1),
        impairment_level: impairment_level(bac)
      }
    end

    private

    def weight_in_grams
      if @unit_system == "imperial"
        @weight * 453.592 # lbs to grams
      else
        @weight * 1000.0 # kg to grams
      end
    end

    def categorize(bac)
      case bac
      when 0.0...0.02 then "Sober"
      when 0.02...0.05 then "Minimal impairment"
      when 0.05...0.08 then "Some impairment"
      when 0.08...0.15 then "Legally impaired"
      when 0.15...0.30 then "Severely impaired"
      else "Life-threatening"
      end
    end

    def impairment_level(bac)
      case bac
      when 0.0...0.02 then "No significant impairment. You may feel normal."
      when 0.02...0.05 then "Slight relaxation and mild mood elevation. Judgment slightly affected."
      when 0.05...0.08 then "Reduced coordination and impaired judgment. Do not drive."
      when 0.08...0.15 then "Above legal limit in most jurisdictions. Significant impairment of motor control."
      when 0.15...0.30 then "Major loss of balance and motor control. Vomiting likely. Blackout risk."
      else "Danger of loss of consciousness, coma, or death. Seek emergency help."
      end
    end

    def validate!
      @errors << "Number of drinks must be positive" unless @drinks > 0
      @errors << "Weight must be positive" unless @weight > 0
      @errors << "Gender must be male or female" unless %w[male female].include?(@gender)
      @errors << "Hours must be zero or positive" unless @hours >= 0
      @errors << "Invalid unit system" unless %w[metric imperial].include?(@unit_system)
    end
  end
end
