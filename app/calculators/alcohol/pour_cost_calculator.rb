# frozen_string_literal: true

module Alcohol
  # Bar pour cost / profitability calculator.
  #
  # Inputs are the bottle cost, bottle size, pour size, and the menu sale price.
  # Outputs the cost per pour, pour cost percentage, gross profit per drink,
  # gross margin, suggested sale price at a target pour cost, and pours per bottle.
  #
  #   pour_cost_per_drink   = bottle_cost * (pour_oz / bottle_oz)
  #   pour_cost_pct         = pour_cost_per_drink / sale_price * 100
  #   profit_per_drink      = sale_price - pour_cost_per_drink
  #   suggested_price       = pour_cost_per_drink / target_pour_cost_pct
  class PourCostCalculator
    attr_reader :errors

    def initialize(bottle_cost:, bottle_size_ml:, pour_size_oz:, sale_price:, target_pour_cost_pct: 20.0)
      @bottle_cost = bottle_cost.to_f
      @bottle_ml = bottle_size_ml.to_f
      @pour_oz = pour_size_oz.to_f
      @sale_price = sale_price.to_f
      @target_pct = target_pour_cost_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bottle_oz = @bottle_ml / 29.5735
      pours_per_bottle = bottle_oz / @pour_oz
      cost_per_oz = @bottle_cost / bottle_oz
      cost_per_pour = cost_per_oz * @pour_oz
      pour_cost_pct = (cost_per_pour / @sale_price) * 100.0
      profit_per_pour = @sale_price - cost_per_pour
      gross_margin_pct = (profit_per_pour / @sale_price) * 100.0
      suggested_price = cost_per_pour / (@target_pct / 100.0)
      profit_per_bottle = profit_per_pour * pours_per_bottle

      {
        valid: true,
        bottle_oz: bottle_oz.round(2),
        cost_per_oz: cost_per_oz.round(3),
        cost_per_pour: cost_per_pour.round(2),
        pour_cost_pct: pour_cost_pct.round(1),
        profit_per_pour: profit_per_pour.round(2),
        gross_margin_pct: gross_margin_pct.round(1),
        pours_per_bottle: pours_per_bottle.round(1),
        suggested_sale_price: suggested_price.round(2),
        profit_per_bottle: profit_per_bottle.round(2),
        rating: rating(pour_cost_pct)
      }
    end

    private

    def rating(pct)
      case pct
      when 0...15 then "Excellent (under industry average)"
      when 15...20 then "Very good (premium bar territory)"
      when 20...25 then "Good (industry standard)"
      when 25...30 then "Below average (review pricing)"
      else "Poor (raise price or cut cost)"
      end
    end

    def validate!
      @errors << "Bottle cost must be greater than zero" unless @bottle_cost.positive?
      @errors << "Bottle size must be greater than zero" unless @bottle_ml.positive?
      @errors << "Pour size must be greater than zero" unless @pour_oz.positive?
      @errors << "Sale price must be greater than zero" unless @sale_price.positive?
      @errors << "Target pour cost % must be between 1 and 100" unless @target_pct.between?(1, 100)
      bottle_oz = @bottle_ml / 29.5735
      @errors << "Pour size cannot exceed bottle size" if @pour_oz > bottle_oz
    end
  end
end
