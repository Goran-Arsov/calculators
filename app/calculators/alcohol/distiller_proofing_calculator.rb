# frozen_string_literal: true

module Alcohol
  # Calculates the water needed to dilute high-proof spirit to a target bottling strength.
  #
  # Uses the Pearson square / dilution equation:
  #
  #   V_final = V_start * (ABV_start / ABV_target)
  #   V_water_to_add = V_final - V_start
  #
  # NOTE: This is a volume-based dilution and ignores the small contraction that occurs
  # when ethanol and water are mixed (~2-3% at common bottling proofs). For licensed
  # distillers, an alcoholometer or hydrometer reading after blending is the legally
  # required final check; the result here is a planning estimate.
  class DistillerProofingCalculator
    attr_reader :errors

    def initialize(start_abv_pct:, start_volume_l:, target_abv_pct:)
      @start_abv = start_abv_pct.to_f
      @start_vol = start_volume_l.to_f
      @target_abv = target_abv_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      final_volume_l = @start_vol * (@start_abv / @target_abv)
      water_to_add_l = final_volume_l - @start_vol

      {
        valid: true,
        start_proof: (@start_abv * 2).round(1),
        target_proof: (@target_abv * 2).round(1),
        final_volume_l: final_volume_l.round(3),
        final_volume_gal: (final_volume_l / 3.78541).round(3),
        water_to_add_l: water_to_add_l.round(3),
        water_to_add_gal: (water_to_add_l / 3.78541).round(3),
        water_to_add_ml: (water_to_add_l * 1000).round(1),
        dilution_ratio: (water_to_add_l / @start_vol).round(3)
      }
    end

    private

    def validate!
      @errors << "Starting ABV must be between 0.1% and 95%" unless @start_abv.between?(0.1, 95)
      @errors << "Target ABV must be greater than zero" unless @target_abv.positive?
      @errors << "Target ABV must be less than starting ABV" if @target_abv >= @start_abv
      @errors << "Starting volume must be greater than zero" unless @start_vol.positive?
    end
  end
end
