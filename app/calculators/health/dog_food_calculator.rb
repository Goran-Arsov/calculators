# frozen_string_literal: true

module Health
  class DogFoodCalculator
    attr_reader :errors

    VALID_ACTIVITY_LEVELS = %w[low normal active very_active].freeze
    VALID_AGE_CATEGORIES = %w[puppy adult senior].freeze
    LBS_TO_KG = 0.453592
    DEFAULT_KCAL_PER_CUP = 350

    # Multipliers applied to RER based on activity level and age category
    MULTIPLIERS = {
      "puppy" => { "low" => 2.0, "normal" => 2.5, "active" => 3.0, "very_active" => 3.0 },
      "adult" => { "low" => 1.2, "normal" => 1.4, "active" => 1.6, "very_active" => 2.0 },
      "senior" => { "low" => 1.0, "normal" => 1.2, "active" => 1.4, "very_active" => 1.6 }
    }.freeze

    def initialize(weight_lbs:, activity_level: "normal", age_category: "adult", kcal_per_cup: DEFAULT_KCAL_PER_CUP)
      @weight_lbs = weight_lbs.to_f
      @activity_level = activity_level.to_s
      @age_category = age_category.to_s
      @kcal_per_cup = kcal_per_cup.to_f
      @kcal_per_cup = DEFAULT_KCAL_PER_CUP if @kcal_per_cup <= 0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @weight_lbs * LBS_TO_KG
      rer = calculate_rer(weight_kg)
      multiplier = MULTIPLIERS[@age_category][@activity_level]
      daily_calories = rer * multiplier
      cups_per_day = daily_calories / @kcal_per_cup
      per_meal = cups_per_day / 2.0

      {
        valid: true,
        weight_lbs: @weight_lbs,
        weight_kg: weight_kg.round(1),
        activity_level: @activity_level,
        age_category: @age_category,
        rer: rer.round(0),
        multiplier: multiplier,
        daily_calories: daily_calories.round(0),
        cups_per_day: cups_per_day.round(2),
        per_meal_cups: per_meal.round(2),
        kcal_per_cup: @kcal_per_cup.round(0)
      }
    end

    private

    def calculate_rer(weight_kg)
      70.0 * (weight_kg**0.75)
    end

    def validate!
      @errors << "Weight must be positive" unless @weight_lbs > 0
      @errors << "Weight must be realistic (up to 350 lbs)" unless @weight_lbs <= 350
      @errors << "Activity level must be low, normal, active, or very_active" unless VALID_ACTIVITY_LEVELS.include?(@activity_level)
      @errors << "Age category must be puppy, adult, or senior" unless VALID_AGE_CATEGORIES.include?(@age_category)
      @errors << "Calorie density must be positive" unless @kcal_per_cup > 0
    end
  end
end
