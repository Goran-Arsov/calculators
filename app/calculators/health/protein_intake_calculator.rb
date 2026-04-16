# frozen_string_literal: true

module Health
  class ProteinIntakeCalculator
    attr_reader :errors

    BASE_RATES = {
      "sedentary" => 0.8,
      "lightly_active" => 1.0,
      "moderately_active" => 1.2,
      "very_active" => 1.6,
      "athlete" => 2.0
    }.freeze

    GOAL_ADJUSTMENTS = {
      "maintain" => 0.0,
      "muscle_gain" => 0.4,
      "fat_loss" => 0.2
    }.freeze

    MEALS_PER_DAY = 4
    CALORIES_PER_GRAM = 4
    REFERENCE_DAILY_CALORIES = 2000

    def initialize(weight_kg:, activity_level:, goal:)
      @weight_kg = weight_kg.to_f
      @activity_level = activity_level.to_s
      @goal = goal.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base_rate = BASE_RATES[@activity_level]
      goal_adj = GOAL_ADJUSTMENTS[@goal]
      protein_per_kg = base_rate + goal_adj
      daily_protein_grams = @weight_kg * protein_per_kg
      per_meal_grams = daily_protein_grams / MEALS_PER_DAY
      protein_calories = daily_protein_grams * CALORIES_PER_GRAM
      protein_pct = (protein_calories / REFERENCE_DAILY_CALORIES) * 100

      {
        valid: true,
        daily_protein_grams: daily_protein_grams.round(1),
        protein_per_kg: protein_per_kg.round(2),
        per_meal_grams: per_meal_grams.round(1),
        protein_calories: protein_calories.round(0),
        protein_pct_of_2000cal: protein_pct.round(1)
      }
    end

    private

    def validate!
      @errors << "Weight must be positive" unless @weight_kg > 0
      @errors << "Weight cannot exceed 500 kg" if @weight_kg > 500
      @errors << "Invalid activity level" unless BASE_RATES.key?(@activity_level)
      @errors << "Invalid goal" unless GOAL_ADJUSTMENTS.key?(@goal)
    end
  end
end
