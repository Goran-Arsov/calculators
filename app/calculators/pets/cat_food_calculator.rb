# frozen_string_literal: true

module Pets
  class CatFoodCalculator
    attr_reader :errors

    VALID_ACTIVITY_LEVELS = %w[inactive moderate active very_active].freeze
    VALID_AGE_CATEGORIES = %w[kitten adult senior].freeze
    VALID_ENVIRONMENTS = %w[indoor outdoor both].freeze

    LBS_TO_KG = 0.453592
    DEFAULT_KCAL_PER_CAN = 250
    OZ_PER_CAN = 5.5

    # Base calories per kg of body weight, adjusted by activity
    ACTIVITY_MULTIPLIERS = {
      "inactive" => 0.8,
      "moderate" => 1.0,
      "active" => 1.2,
      "very_active" => 1.4
    }.freeze

    # Life-stage multipliers applied to base RER
    AGE_MULTIPLIERS = {
      "kitten" => 2.5,
      "adult" => 1.2,
      "senior" => 1.0
    }.freeze

    ENVIRONMENT_ADJUSTMENTS = {
      "indoor" => 0.0,
      "outdoor" => 0.1,
      "both" => 0.05
    }.freeze

    def initialize(weight_lbs:, age_category: "adult", activity_level: "moderate", environment: "indoor", kcal_per_can: DEFAULT_KCAL_PER_CAN)
      @weight_lbs = weight_lbs.to_f
      @age_category = age_category.to_s
      @activity_level = activity_level.to_s
      @environment = environment.to_s
      @kcal_per_can = kcal_per_can.to_f
      @kcal_per_can = DEFAULT_KCAL_PER_CAN if @kcal_per_can <= 0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_kg = @weight_lbs * LBS_TO_KG
      rer = calculate_rer(weight_kg)
      daily_calories = calculate_daily_calories(rer)
      cans_per_day = daily_calories / @kcal_per_can
      oz_per_day = cans_per_day * OZ_PER_CAN

      {
        valid: true,
        weight_lbs: @weight_lbs,
        weight_kg: weight_kg.round(1),
        age_category: @age_category,
        activity_level: @activity_level,
        environment: @environment,
        rer: rer.round(0),
        daily_calories: daily_calories.round(0),
        cans_per_day: cans_per_day.round(2),
        oz_per_day: oz_per_day.round(1),
        kcal_per_can: @kcal_per_can.round(0)
      }
    end

    private

    # RER for cats: 70 * (weight_kg ^ 0.75)
    def calculate_rer(weight_kg)
      70.0 * (weight_kg**0.75)
    end

    def calculate_daily_calories(rer)
      age_factor = AGE_MULTIPLIERS[@age_category]
      activity_factor = ACTIVITY_MULTIPLIERS[@activity_level]
      environment_bonus = ENVIRONMENT_ADJUSTMENTS[@environment]
      rer * age_factor * (activity_factor + environment_bonus)
    end

    def validate!
      @errors << "Weight must be positive" unless @weight_lbs > 0
      @errors << "Weight must be realistic for a cat (up to 30 lbs)" if @weight_lbs > 30
      @errors << "Activity level must be #{VALID_ACTIVITY_LEVELS.join(', ')}" unless VALID_ACTIVITY_LEVELS.include?(@activity_level)
      @errors << "Age category must be #{VALID_AGE_CATEGORIES.join(', ')}" unless VALID_AGE_CATEGORIES.include?(@age_category)
      @errors << "Environment must be #{VALID_ENVIRONMENTS.join(', ')}" unless VALID_ENVIRONMENTS.include?(@environment)
    end
  end
end
