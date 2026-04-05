# frozen_string_literal: true

module Everyday
  class PricePerWeightCalculator
    attr_reader :errors

    # Conversion factors to grams
    GRAMS_PER = {
      "g"  => 1.0,
      "kg" => 1000.0,
      "oz" => 28.3495,
      "lb" => 453.592
    }.freeze

    GRAMS_PER_KG = 1000.0
    GRAMS_PER_LB = 453.592

    def initialize(price:, weight:, unit:)
      @price = price.to_f
      @weight = weight.to_f
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      weight_in_grams = @weight * GRAMS_PER[@unit]
      price_per_gram = @price / weight_in_grams

      price_per_kg = price_per_gram * GRAMS_PER_KG
      price_per_lb = price_per_gram * GRAMS_PER_LB
      price_per_100g = price_per_gram * 100.0

      {
        valid: true,
        price_per_kg: price_per_kg.round(2),
        price_per_lb: price_per_lb.round(2),
        price_per_100g: price_per_100g.round(2),
        price_per_gram: price_per_gram.round(4),
        weight_in_grams: weight_in_grams.round(2)
      }
    end

    private

    def validate!
      @errors << "Price must be greater than zero" unless @price.positive?
      @errors << "Weight must be greater than zero" unless @weight.positive?
      @errors << "Unit must be g, kg, oz, or lb" unless GRAMS_PER.key?(@unit)
    end
  end
end
