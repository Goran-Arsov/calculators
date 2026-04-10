# frozen_string_literal: true

module Alcohol
  # Corrects a hydrometer specific gravity reading for the temperature of the sample.
  # Uses the standard polynomial correction equation:
  #
  #   correction = 1.313454 - 0.132674*T + 2.057793e-3*T^2 - 2.627634e-6*T^3
  #
  # where T is the sample temperature in degrees Fahrenheit. The correction value is added
  # in the *thousandths* place to the measured gravity to get the corrected reading
  # (relative to a 60°F calibrated hydrometer).
  class HydrometerCorrectionCalculator
    attr_reader :errors

    def initialize(measured_gravity:, sample_temp_f:, calibration_temp_f: 60.0)
      @measured = measured_gravity.to_f
      @sample_temp_f = sample_temp_f.to_f
      @cal_temp_f = calibration_temp_f.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sample_corr = polynomial(@sample_temp_f)
      cal_corr = polynomial(@cal_temp_f)
      adjustment = (sample_corr - cal_corr) / 1000.0
      corrected = @measured + adjustment

      {
        valid: true,
        measured_gravity: @measured.round(4),
        corrected_gravity: corrected.round(4),
        adjustment: adjustment.round(4),
        sample_temp_c: ((@sample_temp_f - 32) * 5.0 / 9.0).round(1),
        sample_brix: gravity_to_brix(corrected).round(2)
      }
    end

    private

    def polynomial(t)
      1.313454 - 0.132674 * t + 2.057793e-3 * (t ** 2) - 2.627634e-6 * (t ** 3)
    end

    # Approximate SG to Brix using the standard wort approximation.
    def gravity_to_brix(sg)
      (((182.4601 * sg - 775.6821) * sg + 1262.7794) * sg) - 669.5622
    end

    def validate!
      @errors << "Measured gravity must be between 0.980 and 1.200" unless @measured.between?(0.98, 1.2)
      @errors << "Sample temperature must be between 32°F and 212°F" unless @sample_temp_f.between?(32, 212)
      @errors << "Calibration temperature must be between 32°F and 212°F" unless @cal_temp_f.between?(32, 212)
    end
  end
end
