# frozen_string_literal: true

module Textile
  class FabricGsmCalculator
    attr_reader :errors

    OZ_PER_SQYD_FACTOR = 0.0294935

    def initialize(sample_weight_g:, sample_length_cm:, sample_width_cm:)
      @sample_weight_g = sample_weight_g.to_f
      @sample_length_cm = sample_length_cm.to_f
      @sample_width_cm = sample_width_cm.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sample_area_m2 = (@sample_length_cm * @sample_width_cm) / 10_000.0
      gsm = @sample_weight_g / sample_area_m2
      oz_per_sqyd = gsm * OZ_PER_SQYD_FACTOR

      {
        valid: true,
        gsm: gsm.round(2),
        oz_per_sqyd: oz_per_sqyd.round(3),
        classification: classify(gsm),
        sample_area_m2: sample_area_m2.round(6)
      }
    end

    private

    def classify(gsm)
      if gsm < 100
        "Lightweight (chiffon, voile, organza, muslin)"
      elsif gsm < 200
        "Medium-light (poplin, cotton lawn, shirting)"
      elsif gsm < 300
        "Medium (quilting cotton, linen, standard t-shirt jersey)"
      elsif gsm < 400
        "Medium-heavy (twill, canvas, denim)"
      elsif gsm < 600
        "Heavy (upholstery, duck, heavy denim)"
      else
        "Very heavy (canvas tarp, heavy upholstery)"
      end
    end

    def validate!
      @errors << "Sample weight must be greater than zero" unless @sample_weight_g.positive?
      @errors << "Sample length must be greater than zero" unless @sample_length_cm.positive?
      @errors << "Sample width must be greater than zero" unless @sample_width_cm.positive?
    end
  end
end
