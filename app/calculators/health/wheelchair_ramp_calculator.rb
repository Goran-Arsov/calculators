# frozen_string_literal: true

module Health
  class WheelchairRampCalculator
    attr_reader :errors

    # ADA requires 1:12 slope (1 inch rise per 12 inches run)
    ADA_RATIO = 12
    # Commercial/public buildings often use 1:16 for easier access
    COMMERCIAL_RATIO = 16
    # Maximum single ramp run before a landing is required (ADA)
    MAX_RUN_BEFORE_LANDING_INCHES = 360 # 30 feet
    LANDING_LENGTH_INCHES = 60 # 5 feet minimum landing

    def initialize(rise:, unit: "inches")
      @rise = rise.to_f
      @unit = unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      rise_inches = @unit == "cm" ? @rise / 2.54 : @rise

      ada_run = rise_inches * ADA_RATIO
      commercial_run = rise_inches * COMMERCIAL_RATIO

      ada_length = Math.sqrt(rise_inches**2 + ada_run**2)
      commercial_length = Math.sqrt(rise_inches**2 + commercial_run**2)

      ada_angle = Math.atan2(rise_inches, ada_run) * 180 / Math::PI
      commercial_angle = Math.atan2(rise_inches, commercial_run) * 180 / Math::PI

      ada_landings = (ada_run / MAX_RUN_BEFORE_LANDING_INCHES).ceil
      ada_landings = [ ada_landings - 1, 0 ].max
      commercial_landings = (commercial_run / MAX_RUN_BEFORE_LANDING_INCHES).ceil
      commercial_landings = [ commercial_landings - 1, 0 ].max

      ada_total_with_landings = ada_run + (ada_landings * LANDING_LENGTH_INCHES)
      commercial_total_with_landings = commercial_run + (commercial_landings * LANDING_LENGTH_INCHES)

      {
        valid: true,
        rise_inches: rise_inches.round(1),
        rise_cm: (rise_inches * 2.54).round(1),
        rise_feet: (rise_inches / 12.0).round(2),
        ada: {
          ratio: "1:#{ADA_RATIO}",
          run_inches: ada_run.round(1),
          run_feet: (ada_run / 12.0).round(2),
          run_meters: (ada_run * 0.0254).round(2),
          ramp_length_inches: ada_length.round(1),
          ramp_length_feet: (ada_length / 12.0).round(2),
          angle_degrees: ada_angle.round(2),
          landings_required: ada_landings,
          total_horizontal_inches: ada_total_with_landings.round(1),
          total_horizontal_feet: (ada_total_with_landings / 12.0).round(2)
        },
        commercial: {
          ratio: "1:#{COMMERCIAL_RATIO}",
          run_inches: commercial_run.round(1),
          run_feet: (commercial_run / 12.0).round(2),
          run_meters: (commercial_run * 0.0254).round(2),
          ramp_length_inches: commercial_length.round(1),
          ramp_length_feet: (commercial_length / 12.0).round(2),
          angle_degrees: commercial_angle.round(2),
          landings_required: commercial_landings,
          total_horizontal_inches: commercial_total_with_landings.round(1),
          total_horizontal_feet: (commercial_total_with_landings / 12.0).round(2)
        },
        max_run_before_landing_ft: (MAX_RUN_BEFORE_LANDING_INCHES / 12.0).round(1),
        landing_length_ft: (LANDING_LENGTH_INCHES / 12.0).round(1)
      }
    end

    private

    def validate!
      @errors << "Rise must be positive" unless @rise > 0
      @errors << "Rise seems unrealistically high (max 120 inches / 300 cm)" if (@unit == "cm" && @rise > 300) || (@unit != "cm" && @rise > 120)
      unless %w[inches cm].include?(@unit)
        @errors << "Unit must be inches or cm"
      end
    end
  end
end
