# frozen_string_literal: true

module Cooking
  class MealPrepCostCalculator
    attr_reader :errors

    def initialize(servings:, ingredients: [])
      @servings = servings.to_i
      @ingredients = ingredients # Array of { name:, cost:, quantity_used:, quantity_purchased: }
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ingredient_costs = @ingredients.map do |ingredient|
        cost = ingredient[:cost].to_f
        qty_used = ingredient[:quantity_used].to_f
        qty_purchased = ingredient[:quantity_purchased].to_f

        cost_per_unit = cost / qty_purchased
        cost_used = cost_per_unit * qty_used

        {
          name: ingredient[:name],
          total_cost: cost,
          quantity_used: qty_used,
          quantity_purchased: qty_purchased,
          cost_per_unit: cost_per_unit.round(2),
          cost_used: cost_used.round(2)
        }
      end

      total_cost = ingredient_costs.sum { |i| i[:cost_used] }
      cost_per_serving = total_cost / @servings

      {
        valid: true,
        servings: @servings,
        ingredients: ingredient_costs,
        total_cost: total_cost.round(2),
        cost_per_serving: cost_per_serving.round(2),
        daily_cost_3_meals: (cost_per_serving * 3).round(2),
        weekly_cost: (cost_per_serving * @servings * 7.0 / @servings).round(2)
      }
    end

    private

    def validate!
      @errors << "Servings must be positive" unless @servings > 0
      @errors << "At least one ingredient is required" if @ingredients.empty?
      @ingredients.each_with_index do |ingredient, index|
        @errors << "Ingredient #{index + 1}: cost must be positive" unless ingredient[:cost].to_f > 0
        @errors << "Ingredient #{index + 1}: quantity used must be positive" unless ingredient[:quantity_used].to_f > 0
        @errors << "Ingredient #{index + 1}: quantity purchased must be positive" unless ingredient[:quantity_purchased].to_f > 0
      end
    end
  end
end
