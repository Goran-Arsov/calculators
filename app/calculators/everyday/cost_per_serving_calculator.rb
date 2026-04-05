# frozen_string_literal: true

module Everyday
  class CostPerServingCalculator
    attr_reader :errors

    def initialize(total_cost:, servings:, markup_percent: 0)
      @total_cost = total_cost.to_f
      @servings = servings.to_f
      @markup_percent = markup_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      cost_per_serving = @total_cost / @servings
      selling_price_per_serving = cost_per_serving * (1 + @markup_percent / 100.0)
      profit_per_serving = selling_price_per_serving - cost_per_serving
      total_revenue = selling_price_per_serving * @servings
      total_profit = profit_per_serving * @servings

      {
        cost_per_serving: cost_per_serving.round(2),
        selling_price_per_serving: selling_price_per_serving.round(2),
        profit_per_serving: profit_per_serving.round(2),
        total_revenue: total_revenue.round(2),
        total_profit: total_profit.round(2),
        total_cost: @total_cost.round(2),
        servings: @servings.round(1)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Number of servings must be greater than zero" unless @servings.positive?
      @errors << "Markup percent cannot be negative" if @markup_percent.negative?
    end
  end
end
