# frozen_string_literal: true

module Health
  class CaloriesPerServingCalculator
    attr_reader :errors

    CALORIES_PER_GRAM_PROTEIN = 4
    CALORIES_PER_GRAM_CARBS = 4
    CALORIES_PER_GRAM_FAT = 9

    def initialize(total_calories:, servings:, total_protein: 0, total_carbs: 0, total_fat: 0)
      @total_calories = total_calories.to_f
      @servings = servings.to_f
      @total_protein = total_protein.to_f
      @total_carbs = total_carbs.to_f
      @total_fat = total_fat.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      calories_per_serving = @total_calories / @servings
      protein_per_serving = @total_protein / @servings
      carbs_per_serving = @total_carbs / @servings
      fat_per_serving = @total_fat / @servings

      protein_calories = protein_per_serving * CALORIES_PER_GRAM_PROTEIN
      carbs_calories = carbs_per_serving * CALORIES_PER_GRAM_CARBS
      fat_calories = fat_per_serving * CALORIES_PER_GRAM_FAT

      {
        valid: true,
        calories_per_serving: calories_per_serving.round(1),
        protein_per_serving: protein_per_serving.round(1),
        carbs_per_serving: carbs_per_serving.round(1),
        fat_per_serving: fat_per_serving.round(1),
        protein_calories_per_serving: protein_calories.round(1),
        carbs_calories_per_serving: carbs_calories.round(1),
        fat_calories_per_serving: fat_calories.round(1),
        total_servings: @servings.round(0).to_i
      }
    end

    private

    def validate!
      @errors << "Total calories must be positive" unless @total_calories > 0
      @errors << "Number of servings must be positive" unless @servings > 0
      @errors << "Total protein cannot be negative" if @total_protein < 0
      @errors << "Total carbs cannot be negative" if @total_carbs < 0
      @errors << "Total fat cannot be negative" if @total_fat < 0
    end
  end
end
