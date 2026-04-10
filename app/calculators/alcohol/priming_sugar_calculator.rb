# frozen_string_literal: true

module Alcohol
  # Calculates priming sugar for bottle conditioning beer.
  #
  # Residual CO2 already dissolved in the beer is computed from fermentation temperature
  # using the standard equation:
  #
  #   residual_co2 = 3.0378 - 0.050062 * T + 0.00026555 * T^2     (T in °F)
  #
  # The additional CO2 needed is (target - residual). Each gram of corn sugar (dextrose)
  # produces ~0.5 g CO2 per gram. The grams of corn sugar per liter to raise CO2 by 1 vol:
  #
  #   grams_corn_sugar_per_L_per_vol = 1.965
  #
  # Sucrose (table sugar) is ~91% as much, DME ~1.47x.
  class PrimingSugarCalculator
    attr_reader :errors

    SUGAR_FACTORS = {
      "corn_sugar" => 1.0,    # dextrose monohydrate (reference)
      "table_sugar" => 0.91,  # sucrose, slightly more efficient
      "dme" => 1.47           # dry malt extract
    }.freeze

    BASE_GRAMS_PER_L_PER_VOL = 3.97  # corn sugar grams to raise 1 L of beer by 1 vol CO2

    def initialize(batch_volume_gal:, fermentation_temp_f:, target_co2_volumes:, sugar_type: "corn_sugar")
      @volume_gal = batch_volume_gal.to_f
      @temp_f = fermentation_temp_f.to_f
      @target_co2 = target_co2_volumes.to_f
      @sugar_type = sugar_type.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      residual = 3.0378 - 0.050062 * @temp_f + 0.00026555 * (@temp_f ** 2)
      additional = @target_co2 - residual
      additional = 0.0 if additional.negative?

      volume_l = @volume_gal * 3.78541
      sugar_grams = additional * volume_l * BASE_GRAMS_PER_L_PER_VOL * SUGAR_FACTORS[@sugar_type]
      sugar_oz = sugar_grams / 28.3495

      {
        valid: true,
        residual_co2_volumes: residual.round(2),
        additional_co2_volumes: additional.round(2),
        sugar_grams: sugar_grams.round(1),
        sugar_oz: sugar_oz.round(2),
        sugar_type: @sugar_type,
        batch_volume_l: volume_l.round(2),
        carbonation_style: carbonation_style(@target_co2)
      }
    end

    private

    def carbonation_style(co2)
      case co2
      when 0...1.5 then "Cask ales (English real ale)"
      when 1.5...2.0 then "British / Irish ales"
      when 2.0...2.5 then "American ales, porters, stouts"
      when 2.5...3.0 then "European lagers, IPAs"
      when 3.0...4.0 then "Belgian ales, wheat beers"
      else "Highly carbonated (champagne-like)"
      end
    end

    def validate!
      @errors << "Batch volume must be greater than zero" unless @volume_gal.positive?
      @errors << "Fermentation temperature must be between 32°F and 100°F" unless @temp_f.between?(32, 100)
      @errors << "Target CO2 volumes must be between 0.5 and 5.0" unless @target_co2.between?(0.5, 5.0)
      @errors << "Sugar type must be one of: #{SUGAR_FACTORS.keys.join(', ')}" unless SUGAR_FACTORS.key?(@sugar_type)
    end
  end
end
