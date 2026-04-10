# frozen_string_literal: true

module Alcohol
  # Calculates the strike water temperature needed to hit a target mash temperature
  # using John Palmer's infusion equation:
  #
  #   Tw = (0.2 / R) * (T2 - T1) + T2
  #
  # Where:
  #   Tw = strike water temperature
  #   R  = water-to-grain ratio (qt / lb)
  #   T1 = grain initial temperature
  #   T2 = target mash temperature
  #
  # The 0.2 constant is the specific heat ratio of grain to water.
  class StrikeWaterCalculator
    attr_reader :errors

    def initialize(grain_weight_lb:, grain_temp_f:, target_mash_temp_f:, water_to_grain_ratio_qt_per_lb: 1.25)
      @grain_weight_lb = grain_weight_lb.to_f
      @grain_temp_f = grain_temp_f.to_f
      @target_mash_temp_f = target_mash_temp_f.to_f
      @ratio = water_to_grain_ratio_qt_per_lb.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      strike_temp = (0.2 / @ratio) * (@target_mash_temp_f - @grain_temp_f) + @target_mash_temp_f
      water_quarts = @grain_weight_lb * @ratio
      water_gallons = water_quarts / 4.0
      water_liters = water_quarts * 0.946353

      {
        valid: true,
        strike_water_temp_f: strike_temp.round(1),
        strike_water_temp_c: ((strike_temp - 32) * 5.0 / 9.0).round(1),
        water_volume_qt: water_quarts.round(2),
        water_volume_gal: water_gallons.round(2),
        water_volume_l: water_liters.round(2),
        target_mash_temp_c: ((@target_mash_temp_f - 32) * 5.0 / 9.0).round(1)
      }
    end

    private

    def validate!
      @errors << "Grain weight must be greater than zero" unless @grain_weight_lb.positive?
      @errors << "Grain temperature must be between 32°F and 120°F" unless @grain_temp_f.between?(32, 120)
      @errors << "Target mash temperature must be between 90°F and 170°F" unless @target_mash_temp_f.between?(90, 170)
      @errors << "Water-to-grain ratio must be greater than zero" unless @ratio.positive?
      @errors << "Target mash temperature must be higher than grain temperature" if @target_mash_temp_f <= @grain_temp_f
    end
  end
end
