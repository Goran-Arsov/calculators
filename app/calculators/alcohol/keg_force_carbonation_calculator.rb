# frozen_string_literal: true

module Alcohol
  # Calculates the regulator pressure (PSI) required to force carbonate a keg of beer
  # to a target CO2 volumes at a given serving temperature.
  #
  # Uses the standard solubility-of-CO2 polynomial widely used by homebrew calculators
  # (derived from carbonation tables in "How to Brew" by John Palmer):
  #
  #   PSI = -16.6999
  #         - 0.0101059 * T
  #         + 0.00116512 * T^2
  #         + 0.173354 * T * V
  #         + 4.24267 * V
  #         - 0.0684226 * V^2
  #
  # where T is the beer temperature in °F and V is the target CO2 volumes.
  class KegForceCarbonationCalculator
    attr_reader :errors

    def initialize(beer_temp_f:, target_co2_volumes:)
      @temp_f = beer_temp_f.to_f
      @vols = target_co2_volumes.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      psi = -16.6999 -
            0.0101059 * @temp_f +
            0.00116512 * (@temp_f ** 2) +
            0.173354 * @temp_f * @vols +
            4.24267 * @vols -
            0.0684226 * (@vols ** 2)
      psi = 0.0 if psi.negative?

      {
        valid: true,
        regulator_psi: psi.round(1),
        regulator_kpa: (psi * 6.89476).round(1),
        beer_temp_c: ((@temp_f - 32) * 5.0 / 9.0).round(1),
        target_co2_volumes: @vols.round(2),
        carbonation_style: style(@vols)
      }
    end

    private

    def style(v)
      case v
      when 0...1.5 then "British real ale (cask conditioned)"
      when 1.5...2.0 then "English bitter, Irish stout"
      when 2.0...2.5 then "American ales, porter, brown ale"
      when 2.5...3.0 then "American lager, pilsner, IPA"
      when 3.0...4.0 then "Belgian ales, wheat beer"
      else "Highly sparkling (saison, lambic)"
      end
    end

    def validate!
      @errors << "Beer temperature must be between 28°F and 80°F" unless @temp_f.between?(28, 80)
      @errors << "Target CO2 volumes must be between 0.5 and 5.0" unless @vols.between?(0.5, 5.0)
    end
  end
end
