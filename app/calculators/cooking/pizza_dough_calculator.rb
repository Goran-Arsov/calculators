# frozen_string_literal: true

module Cooking
  class PizzaDoughCalculator
    attr_reader :errors

    # Standard dough ball weights by pizza size (grams)
    DOUGH_BALL_WEIGHTS = {
      "small" => 200,   # ~10 inch
      "medium" => 250,  # ~12 inch
      "large" => 300,   # ~14 inch
      "extra_large" => 350 # ~16 inch
    }.freeze

    # Default baker's percentages
    DEFAULT_SALT_PCT = 2.5   # % of flour
    DEFAULT_YEAST_PCT = 0.3  # % of flour (for long ferment; 1% for same-day)
    DEFAULT_OIL_PCT = 3.0    # % of flour
    DEFAULT_SUGAR_PCT = 1.0  # % of flour

    def initialize(num_pizzas:, size: "medium", hydration: 65, ferment_time: "long", include_oil: true, include_sugar: false)
      @num_pizzas = num_pizzas.to_i
      @size = size.to_s.strip
      @hydration = hydration.to_f / 100.0
      @ferment_time = ferment_time.to_s.strip
      @include_oil = include_oil
      @include_sugar = include_sugar
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      dough_ball_weight = DOUGH_BALL_WEIGHTS[@size]
      total_dough_weight = dough_ball_weight * @num_pizzas

      # Baker's percentages: flour = 100%, water = hydration%, etc.
      # Total percentage = 100 + hydration + salt + yeast + (oil) + (sugar)
      yeast_pct = yeast_percentage
      total_pct = 1.0 + @hydration + (DEFAULT_SALT_PCT / 100.0) + (yeast_pct / 100.0)
      total_pct += (DEFAULT_OIL_PCT / 100.0) if @include_oil
      total_pct += (DEFAULT_SUGAR_PCT / 100.0) if @include_sugar

      flour = total_dough_weight / total_pct
      water = flour * @hydration
      salt = flour * (DEFAULT_SALT_PCT / 100.0)
      yeast = flour * (yeast_pct / 100.0)
      oil = @include_oil ? flour * (DEFAULT_OIL_PCT / 100.0) : 0.0
      sugar = @include_sugar ? flour * (DEFAULT_SUGAR_PCT / 100.0) : 0.0

      {
        valid: true,
        num_pizzas: @num_pizzas,
        size: @size,
        hydration_pct: (@hydration * 100).round(1),
        dough_ball_weight: dough_ball_weight,
        total_dough_weight: total_dough_weight.round(0),
        flour_g: flour.round(1),
        water_g: water.round(1),
        salt_g: salt.round(1),
        yeast_g: yeast.round(2),
        oil_g: oil.round(1),
        sugar_g: sugar.round(1),
        ferment_time: @ferment_time,
        yeast_type_note: yeast_note
      }
    end

    private

    def validate!
      @errors << "Number of pizzas must be positive" unless @num_pizzas > 0
      @errors << "Unknown pizza size: #{@size}" unless DOUGH_BALL_WEIGHTS.key?(@size)
      @errors << "Hydration must be between 50% and 100%" unless @hydration >= 0.5 && @hydration <= 1.0
    end

    def yeast_percentage
      case @ferment_time
      when "same_day" then 1.0
      when "overnight" then 0.5
      when "long" then 0.3
      when "cold_48h" then 0.15
      else 0.5
      end
    end

    def yeast_note
      case @ferment_time
      when "same_day" then "Active dry or instant yeast. Ready in 2-4 hours at room temperature."
      when "overnight" then "Active dry or instant yeast. 8-12 hours at room temperature."
      when "long" then "Instant yeast preferred. 24 hours cold ferment in fridge."
      when "cold_48h" then "Instant yeast preferred. 48 hours cold ferment in fridge for best flavor."
      else "Adjust yeast based on desired ferment time."
      end
    end
  end
end
