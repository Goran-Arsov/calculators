# frozen_string_literal: true

module Alcohol
  # Calculates International Bitterness Units (IBU) from a list of hop additions
  # using the Tinseth utilization formula:
  #
  #   utilization = bigness_factor * boil_time_factor
  #   bigness_factor = 1.65 * 0.000125 ** (wort_gravity - 1)
  #   boil_time_factor = (1 - e^(-0.04 * boil_time)) / 4.15
  #   IBU = (alpha_acid_decimal * weight_oz * utilization * 7489) / volume_gal
  #
  # Hops are passed as an array of hashes:
  #   [{ weight_oz:, alpha_acid_pct:, boil_time_min: }, ...]
  class IbuCalculator
    attr_reader :errors

    def initialize(hops:, batch_volume_gal:, original_gravity:)
      @hops = Array(hops)
      @volume_gal = batch_volume_gal.to_f
      @og = original_gravity.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bigness = 1.65 * (0.000125 ** (@og - 1.0))

      hop_results = @hops.map do |hop|
        weight = hop[:weight_oz].to_f
        aa = hop[:alpha_acid_pct].to_f / 100.0
        time = hop[:boil_time_min].to_f
        boil_factor = (1.0 - Math.exp(-0.04 * time)) / 4.15
        utilization = bigness * boil_factor
        ibus = (aa * weight * utilization * 7489.0) / @volume_gal
        {
          weight_oz: weight,
          alpha_acid_pct: hop[:alpha_acid_pct].to_f,
          boil_time_min: time,
          utilization_pct: (utilization * 100).round(2),
          ibus: ibus.round(2)
        }
      end

      total_ibu = hop_results.sum { |h| h[:ibus] }

      {
        valid: true,
        total_ibu: total_ibu.round(1),
        bigness_factor: bigness.round(4),
        hop_breakdown: hop_results,
        bitterness_category: bitterness_category(total_ibu)
      }
    end

    private

    def bitterness_category(ibu)
      case ibu
      when 0...10 then "Very low (light lagers, kölsch)"
      when 10...20 then "Low (wheat beer, blonde ale)"
      when 20...30 then "Mild (amber ale, brown ale, stout)"
      when 30...45 then "Moderate (pale ale, porter)"
      when 45...60 then "Assertive (IPA, ESB)"
      when 60...80 then "Strong (American IPA, double IPA)"
      else "Very strong (imperial IPA, hop bomb)"
      end
    end

    def validate!
      @errors << "Batch volume must be greater than zero" unless @volume_gal.positive?
      @errors << "Original gravity must be greater than 1.000" unless @og > 1.0
      @errors << "At least one hop addition is required" if @hops.empty?

      @hops.each_with_index do |hop, i|
        @errors << "Hop ##{i + 1}: weight must be positive" unless hop[:weight_oz].to_f.positive?
        @errors << "Hop ##{i + 1}: alpha acid % must be positive" unless hop[:alpha_acid_pct].to_f.positive?
        @errors << "Hop ##{i + 1}: boil time cannot be negative" if hop[:boil_time_min].to_f.negative?
      end
    end
  end
end
