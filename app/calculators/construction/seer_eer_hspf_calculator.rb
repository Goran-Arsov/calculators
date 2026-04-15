# frozen_string_literal: true

module Construction
  class SeerEerHspfCalculator
    attr_reader :errors

    # Efficiency metrics for heat pumps and air conditioners:
    #   EER = BTU/hr ÷ watts            (steady state, any temperature)
    #   COP = watts_out ÷ watts_in      (dimensionless, any temperature)
    #   SEER = seasonal cooling BTU ÷ seasonal watt-hours   (season average)
    #   HSPF = seasonal heating BTU ÷ seasonal watt-hours   (season average)
    #   SEER2/EER2/HSPF2 are the 2023 testing-procedure versions,
    #     roughly 4-5% lower than the older SEER/EER/HSPF numbers.
    #
    # Useful approximations at AHRI rating conditions:
    #   SEER ≈ EER × 1.12     (steady EER × 12%-ish seasonal adjustment)
    #   SEER ≈ COP × 3.412 × (seasonal factor)
    #   HSPF ≈ COP × 3.412 × (seasonal factor)
    # For a rough converter we use the relationships:
    #   SEER2 ≈ SEER × 0.96
    #   EER2 ≈ EER × 0.954
    #   HSPF2 ≈ HSPF × 0.85
    #   SEER / 3.412 ≈ seasonal COP
    VALID_INPUTS = %w[seer seer2 eer eer2 hspf hspf2 cop].freeze

    SEER_TO_SEER2 = 0.96
    EER_TO_EER2 = 0.954
    HSPF_TO_HSPF2 = 0.85

    def initialize(value:, input_type:)
      @value = value.to_f
      @input_type = input_type.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Convert input to a common "SEER" basis first, then derive all others.
      seer = case @input_type
      when "seer"  then @value
      when "seer2" then @value / SEER_TO_SEER2
      when "eer"   then @value * 1.12           # rough cooling EER → SEER
      when "eer2"  then (@value / EER_TO_EER2) * 1.12
      when "hspf"  then @value                  # HSPF and SEER both in BTU/Wh
      when "hspf2" then @value / HSPF_TO_HSPF2
      when "cop"   then @value * 3.412          # COP → BTU/Wh
      end

      seer2 = seer * SEER_TO_SEER2
      eer = seer / 1.12
      eer2 = eer * EER_TO_EER2
      hspf = seer           # approximate; both are seasonal BTU/Wh
      hspf2 = hspf * HSPF_TO_HSPF2
      cop = seer / 3.412    # BTU/Wh → dimensionless

      {
        valid: true,
        input_type: @input_type,
        input_value: @value.round(3),
        seer: seer.round(2),
        seer2: seer2.round(2),
        eer: eer.round(2),
        eer2: eer2.round(2),
        hspf: hspf.round(2),
        hspf2: hspf2.round(2),
        cop: cop.round(3)
      }
    end

    private

    def validate!
      @errors << "Value must be greater than zero" unless @value.positive?
      @errors << "Input type must be one of #{VALID_INPUTS.join(', ')}" unless VALID_INPUTS.include?(@input_type)
    end
  end
end
