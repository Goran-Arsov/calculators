# frozen_string_literal: true

module Construction
  class RafterLengthCalculator
    attr_reader :errors

    # Pitch notation: rise per 12 inches of run. Common residential pitches:
    # 4/12, 6/12, 8/12, 12/12. A 12/12 pitch = 45° angle.
    def initialize(run_ft:, pitch_rise_per_12:, overhang_in: 0.0)
      @run_ft = run_ft.to_f
      @pitch = pitch_rise_per_12.to_f
      @overhang_in = overhang_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Rise = run × (pitch/12)
      rise_ft = @run_ft * (@pitch / 12.0)
      rafter_length_ft = Math.sqrt(@run_ft**2 + rise_ft**2)
      overhang_ft = @overhang_in / 12.0
      total_rafter_ft = rafter_length_ft + overhang_ft
      angle_deg = Math.atan(@pitch / 12.0) * 180.0 / Math::PI
      grade_pct = (@pitch / 12.0) * 100.0

      {
        valid: true,
        run_ft: @run_ft.round(2),
        rise_ft: rise_ft.round(2),
        rafter_length_ft: rafter_length_ft.round(2),
        total_rafter_ft: total_rafter_ft.round(2),
        overhang_ft: overhang_ft.round(2),
        angle_deg: angle_deg.round(2),
        grade_pct: grade_pct.round(1),
        pitch_notation: "#{@pitch.to_i}/12"
      }
    end

    private

    def validate!
      @errors << "Run must be greater than zero" unless @run_ft.positive?
      @errors << "Pitch must be greater than zero" unless @pitch.positive?
      @errors << "Overhang cannot be negative" if @overhang_in.negative?
    end
  end
end
