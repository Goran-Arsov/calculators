# frozen_string_literal: true

module Alcohol
  # Refractometer Brix to Specific Gravity converter, with optional post-fermentation
  # correction. Uses standard brewing equations:
  #
  # Pre-fermentation:
  #   SG = 1 + (Brix / (258.6 - ((Brix / 258.2) * 227.1)))
  #
  # Post-fermentation (Sean Terrill cubic), corrected for the wort correction factor (WCF):
  #   OB = OG_brix / WCF
  #   FB = FG_brix / WCF
  #   FG = 1 - 0.0044993*OB + 0.011774*FB + 0.00027581*OB^2 - 0.0012717*FB^2 - 0.00000728*OB^3 + 0.000063293*FB^3
  #
  # ABV = (OG - FG) * 131.25
  class BrixToGravityCalculator
    attr_reader :errors

    def initialize(og_brix:, fg_brix: nil, wort_correction_factor: 1.04)
      @og_brix = og_brix.to_f
      @fg_brix = fg_brix.nil? || fg_brix.to_s.strip.empty? ? nil : fg_brix.to_f
      @wcf = wort_correction_factor.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      og = brix_to_sg(@og_brix / @wcf)

      result = {
        valid: true,
        og: og.round(4),
        og_corrected_brix: (@og_brix / @wcf).round(2)
      }

      if @fg_brix
        fg = terrill_fg(@og_brix, @fg_brix, @wcf)
        abv = (og - fg) * 131.25
        result.merge!(
          fg: fg.round(4),
          fg_corrected_brix: (@fg_brix / @wcf).round(2),
          abv: abv.round(2),
          attenuation: (((og - fg) / (og - 1.0)) * 100.0).round(1)
        )
      end

      result
    end

    private

    def brix_to_sg(brix)
      1.0 + (brix / (258.6 - ((brix / 258.2) * 227.1)))
    end

    def terrill_fg(og_b, fg_b, wcf)
      ob = og_b / wcf
      fb = fg_b / wcf
      1.0 - 0.0044993 * ob + 0.011774 * fb +
        0.00027581 * (ob ** 2) - 0.0012717 * (fb ** 2) -
        0.00000728 * (ob ** 3) + 0.000063293 * (fb ** 3)
    end

    def validate!
      @errors << "OG Brix must be between 0 and 40" unless @og_brix.between?(0, 40)
      @errors << "OG Brix must be greater than zero" unless @og_brix.positive?
      @errors << "Wort correction factor must be between 1.0 and 1.1" unless @wcf.between?(1.0, 1.1)
      if @fg_brix
        @errors << "FG Brix must be between 0 and 40" unless @fg_brix.between?(0, 40)
        @errors << "FG Brix cannot exceed OG Brix" if @fg_brix > @og_brix
      end
    end
  end
end
