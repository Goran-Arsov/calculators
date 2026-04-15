# frozen_string_literal: true

module Construction
  class RoofPitchCalculator
    attr_reader :errors

    # Mode "rise_run" accepts rise and run and computes pitch/angle/grade.
    # Mode "angle" accepts degrees and computes pitch/rise/run ratio.
    # Mode "grade" accepts grade % and computes pitch/angle.
    VALID_MODES = %w[rise_run angle grade].freeze

    def initialize(mode: "rise_run", rise_in: nil, run_in: nil, angle_deg: nil, grade_pct: nil)
      @mode = mode.to_s.downcase
      @rise_in = rise_in.to_f if rise_in
      @run_in = run_in.to_f if run_in
      @angle_deg = angle_deg.to_f if angle_deg
      @grade_pct = grade_pct.to_f if grade_pct
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "rise_run"
        ratio = @rise_in / @run_in
      when "angle"
        ratio = Math.tan(@angle_deg * Math::PI / 180.0)
      when "grade"
        ratio = @grade_pct / 100.0
      end

      pitch_x_per_12 = ratio * 12.0
      angle_deg = Math.atan(ratio) * 180.0 / Math::PI
      grade_pct = ratio * 100.0

      {
        valid: true,
        pitch_x_per_12: pitch_x_per_12.round(2),
        pitch_notation: "#{pitch_x_per_12.round(1)}/12",
        angle_deg: angle_deg.round(2),
        grade_pct: grade_pct.round(2),
        slope_category: category_for(pitch_x_per_12)
      }
    end

    private

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be rise_run, angle, or grade"
        return
      end

      case @mode
      when "rise_run"
        @errors << "Rise must be greater than zero" unless @rise_in && @rise_in.positive?
        @errors << "Run must be greater than zero" unless @run_in && @run_in.positive?
      when "angle"
        if @angle_deg.nil? || !@angle_deg.positive? || @angle_deg >= 90
          @errors << "Angle must be between 0 and 90 degrees"
        end
      when "grade"
        @errors << "Grade must be greater than zero" unless @grade_pct && @grade_pct.positive?
      end
    end

    def category_for(pitch)
      if pitch < 2
        "Flat (membrane required)"
      elsif pitch < 4
        "Low slope"
      elsif pitch < 9
        "Conventional slope"
      elsif pitch < 12
        "Steep slope"
      else
        "Very steep slope"
      end
    end
  end
end
