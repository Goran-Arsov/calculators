# frozen_string_literal: true

module Cooking
  class RecipeScalerCalculator
    attr_reader :errors

    def initialize(original_servings:, desired_servings:, ingredients: [])
      @original_servings = original_servings.to_i
      @desired_servings = desired_servings.to_i
      @ingredients = ingredients
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      multiplier = @desired_servings.to_f / @original_servings
      scaled = @ingredients.map do |ingredient|
        {
          name: ingredient[:name],
          original_amount: ingredient[:amount].to_f,
          scaled_amount: (ingredient[:amount].to_f * multiplier).round(2),
          unit: ingredient[:unit]
        }
      end

      {
        valid: true,
        multiplier: multiplier.round(4),
        original_servings: @original_servings,
        desired_servings: @desired_servings,
        scaled_ingredients: scaled
      }
    end

    private

    def validate!
      @errors << "Original servings must be positive" unless @original_servings > 0
      @errors << "Desired servings must be positive" unless @desired_servings > 0
    end
  end
end
