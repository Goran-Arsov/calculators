# frozen_string_literal: true

module Cooking
  class MacrosPerRecipeCalculator
    attr_reader :errors

    def initialize(servings:, ingredients: [])
      @servings = servings.to_i
      @ingredients = ingredients # Array of { name:, calories:, protein_g:, carbs_g:, fat_g:, quantity: }
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_calories = 0.0
      total_protein = 0.0
      total_carbs = 0.0
      total_fat = 0.0

      ingredient_details = @ingredients.map do |ingredient|
        qty = ingredient[:quantity].to_f
        qty = 1.0 if qty <= 0

        cal = ingredient[:calories].to_f * qty
        pro = ingredient[:protein_g].to_f * qty
        carb = ingredient[:carbs_g].to_f * qty
        fat = ingredient[:fat_g].to_f * qty

        total_calories += cal
        total_protein += pro
        total_carbs += carb
        total_fat += fat

        {
          name: ingredient[:name],
          quantity: qty,
          calories: cal.round(1),
          protein_g: pro.round(1),
          carbs_g: carb.round(1),
          fat_g: fat.round(1)
        }
      end

      per_serving_calories = total_calories / @servings
      per_serving_protein = total_protein / @servings
      per_serving_carbs = total_carbs / @servings
      per_serving_fat = total_fat / @servings

      # Macronutrient percentages (by calorie)
      total_macro_cals = (per_serving_protein * 4) + (per_serving_carbs * 4) + (per_serving_fat * 9)
      protein_pct = total_macro_cals > 0 ? ((per_serving_protein * 4) / total_macro_cals * 100) : 0
      carbs_pct = total_macro_cals > 0 ? ((per_serving_carbs * 4) / total_macro_cals * 100) : 0
      fat_pct = total_macro_cals > 0 ? ((per_serving_fat * 9) / total_macro_cals * 100) : 0

      {
        valid: true,
        servings: @servings,
        ingredients: ingredient_details,
        total: {
          calories: total_calories.round(1),
          protein_g: total_protein.round(1),
          carbs_g: total_carbs.round(1),
          fat_g: total_fat.round(1)
        },
        per_serving: {
          calories: per_serving_calories.round(1),
          protein_g: per_serving_protein.round(1),
          carbs_g: per_serving_carbs.round(1),
          fat_g: per_serving_fat.round(1)
        },
        macro_percentages: {
          protein: protein_pct.round(1),
          carbs: carbs_pct.round(1),
          fat: fat_pct.round(1)
        }
      }
    end

    private

    def validate!
      @errors << "Servings must be positive" unless @servings > 0
      @errors << "At least one ingredient is required" if @ingredients.empty?
      @ingredients.each_with_index do |ingredient, index|
        @errors << "Ingredient #{index + 1}: calories must be non-negative" if ingredient[:calories].to_f < 0
      end
    end
  end
end
