# frozen_string_literal: true

module Health
  class CaloriesPer100gCalculator
    attr_reader :errors

    GRAMS_PER_OZ = 28.3495

    # Energy density classifications (calories per 100g)
    # Based on CDC / Volumetrics guidelines
    DENSITY_THRESHOLDS = {
      very_low: 60,    # e.g. fruits, non-starchy vegetables
      low: 150,        # e.g. grains, lean proteins
      medium: 400      # e.g. bread, cheese
      # above 400 = high (e.g. nuts, oils, chocolate)
    }.freeze

    def initialize(calories:, weight_grams:)
      @calories = calories.to_f
      @weight_grams = weight_grams.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      calories_per_100g = (@calories / @weight_grams) * 100
      calories_per_oz = (@calories / @weight_grams) * GRAMS_PER_OZ
      calories_per_gram = @calories / @weight_grams

      density = classify_energy_density(calories_per_100g)

      {
        valid: true,
        calories_per_100g: calories_per_100g.round(1),
        calories_per_oz: calories_per_oz.round(1),
        calories_per_gram: calories_per_gram.round(2),
        energy_density: density,
        original_calories: @calories.round(1),
        original_weight_grams: @weight_grams.round(1)
      }
    end

    private

    def classify_energy_density(cal_per_100g)
      if cal_per_100g <= DENSITY_THRESHOLDS[:very_low]
        "very_low"
      elsif cal_per_100g <= DENSITY_THRESHOLDS[:low]
        "low"
      elsif cal_per_100g <= DENSITY_THRESHOLDS[:medium]
        "medium"
      else
        "high"
      end
    end

    def validate!
      @errors << "Calories must be positive" unless @calories > 0
      @errors << "Weight must be positive" unless @weight_grams > 0
    end
  end
end
