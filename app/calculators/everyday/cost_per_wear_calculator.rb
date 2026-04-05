# frozen_string_literal: true

module Everyday
  class CostPerWearCalculator
    attr_reader :errors

    def initialize(item_price:, estimated_wears:, alternative_price: 0, alternative_wears: 0)
      @item_price = item_price.to_f
      @estimated_wears = estimated_wears.to_f
      @alternative_price = alternative_price.to_f
      @alternative_wears = alternative_wears.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_per_wear = @item_price / @estimated_wears
      result = {
        valid: true,
        cost_per_wear: cost_per_wear.round(2),
        item_price: @item_price.round(2),
        estimated_wears: @estimated_wears.round(0)
      }

      if @alternative_price.positive? && @alternative_wears.positive?
        alt_cost_per_wear = @alternative_price / @alternative_wears
        savings_per_wear = (cost_per_wear - alt_cost_per_wear).round(2)
        better_value = if cost_per_wear < alt_cost_per_wear
                         "Main item"
        elsif alt_cost_per_wear < cost_per_wear
                         "Alternative"
        else
                         "Tie"
        end
        break_even_wears = if alt_cost_per_wear.positive?
                             (@item_price / alt_cost_per_wear).ceil
        else
                             0
        end

        result.merge!(
          alternative_cost_per_wear: alt_cost_per_wear.round(2),
          savings_per_wear: savings_per_wear,
          better_value: better_value,
          break_even_wears: break_even_wears
        )
      end

      result
    end

    private

    def validate!
      @errors << "Item price must be greater than zero" unless @item_price.positive?
      @errors << "Estimated wears must be greater than zero" unless @estimated_wears.positive?
      if @alternative_price.positive? && !@alternative_wears.positive?
        @errors << "Alternative wears must be greater than zero when alternative price is set"
      end
    end
  end
end
