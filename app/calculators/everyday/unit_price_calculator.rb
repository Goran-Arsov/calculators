# frozen_string_literal: true

module Everyday
  class UnitPriceCalculator
    attr_reader :errors

    def initialize(price_a:, quantity_a:, price_b:, quantity_b:, unit: "unit")
      @price_a = price_a.to_f
      @quantity_a = quantity_a.to_f
      @price_b = price_b.to_f
      @quantity_b = quantity_b.to_f
      @unit = unit.to_s.strip
      @unit = "unit" if @unit.empty?
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      unit_price_a = @price_a / @quantity_a
      unit_price_b = @price_b / @quantity_b

      savings_per_unit = (unit_price_a - unit_price_b).abs
      savings_pct = if [ unit_price_a, unit_price_b ].max.positive?
                      (savings_per_unit / [ unit_price_a, unit_price_b ].max) * 100
      else
                      0.0
      end

      better_deal = if unit_price_a < unit_price_b
                      "A"
      elsif unit_price_b < unit_price_a
                      "B"
      else
                      "Tie"
      end

      {
        unit_price_a: unit_price_a.round(4),
        unit_price_b: unit_price_b.round(4),
        better_deal: better_deal,
        savings_per_unit: savings_per_unit.round(4),
        savings_percent: savings_pct.round(2),
        unit: @unit,
        product_a: { price: @price_a, quantity: @quantity_a },
        product_b: { price: @price_b, quantity: @quantity_b }
      }
    end

    private

    def validate!
      @errors << "Price A must be greater than zero" unless @price_a.positive?
      @errors << "Quantity A must be greater than zero" unless @quantity_a.positive?
      @errors << "Price B must be greater than zero" unless @price_b.positive?
      @errors << "Quantity B must be greater than zero" unless @quantity_b.positive?
    end
  end
end
