# frozen_string_literal: true

module Alcohol
  # Calculates alcohol by volume from original (OG) and final (FG) gravity readings.
  #
  # Two formulas are returned:
  #   * Simple (Papazian):  ABV = (OG - FG) * 131.25
  #   * Advanced (Miller):  ABV = (76.08 * (OG - FG) / (1.775 - OG)) * (FG / 0.794)
  #
  # The advanced formula is more accurate for higher-gravity beers (>1.070).
  class AbvCalculator
    attr_reader :errors

    def initialize(original_gravity:, final_gravity:)
      @og = original_gravity.to_f
      @fg = final_gravity.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      abv_simple = (@og - @fg) * 131.25
      abv_advanced = (76.08 * (@og - @fg) / (1.775 - @og)) * (@fg / 0.794)
      abw = abv_advanced * 0.79336 # alcohol by weight ≈ ABV * 0.79336

      attenuation = ((@og - @fg) / (@og - 1.0)) * 100.0
      calories = calories_per_12oz(@og, @fg)

      {
        valid: true,
        abv_simple: abv_simple.round(2),
        abv_advanced: abv_advanced.round(2),
        abw: abw.round(2),
        attenuation: attenuation.round(1),
        calories_per_12oz: calories.round(0),
        gravity_drop: (@og - @fg).round(4)
      }
    end

    private

    # Approximate calories per 12 oz: 1881.22 * (FG - 0.1886 * (OG - FG) / (1.775 - OG)) * (FG - 1.0) / FG
    # plus alcohol calories. Common simplified formula:
    #   cals = ((6.9 * ABW) + 4.0 * (real_extract - 0.1)) * FG * 3.55
    def calories_per_12oz(og, fg)
      real_extract = (0.1808 * ((og - 1) * 1000.0 / 4.0)) + (0.8192 * ((fg - 1) * 1000.0 / 4.0))
      abw = (76.08 * (og - fg) / (1.775 - og)) * (fg / 0.794) * 0.79336
      ((6.9 * abw) + 4.0 * (real_extract - 0.1)) * fg * 3.55
    end

    def validate!
      @errors << "Original gravity must be greater than 1.000" unless @og > 1.0
      @errors << "Final gravity must be greater than 0.980" unless @fg > 0.98
      @errors << "Final gravity cannot be greater than original gravity" if @fg > @og
      @errors << "Original gravity is unrealistically high (max 1.200)" if @og > 1.2
    end
  end
end
