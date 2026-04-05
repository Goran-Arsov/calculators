# frozen_string_literal: true

module Construction
  class StaircaseCalculator
    attr_reader :errors

    # IRC code limits: max riser 7.75", min tread 10"
    MAX_RISER_HEIGHT = 7.75
    MIN_TREAD_DEPTH = 10.0
    IDEAL_RISER_HEIGHT = 7.0  # ideal comfortable riser height in inches

    def initialize(floor_height:, run_preference: nil)
      @floor_height = floor_height.to_f           # total rise in inches
      @run_preference = run_preference.to_f if run_preference.to_s.strip != ""
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      # Calculate number of risers based on ideal riser height
      num_risers = (@floor_height / IDEAL_RISER_HEIGHT).round
      num_risers = [ num_risers, 1 ].max
      rise_per_step = @floor_height / num_risers.to_f

      # Adjust if rise exceeds code maximum
      if rise_per_step > MAX_RISER_HEIGHT
        num_risers += 1
        rise_per_step = @floor_height / num_risers.to_f
      end

      # Number of treads is one less than risers (top floor is final landing)
      num_treads = num_risers - 1

      # Run per step: use preference if provided, else calculate from 17-rule
      # (riser + tread should be ~17-18 inches for comfort)
      if @run_preference && @run_preference > 0
        run_per_step = @run_preference
      else
        run_per_step = [ 17.5 - rise_per_step, MIN_TREAD_DEPTH ].max
      end

      # Total run (horizontal distance)
      total_run = num_treads * run_per_step

      # Stringer length (hypotenuse)
      stringer_length = Math.sqrt(@floor_height**2 + total_run**2)

      # Angle in degrees
      angle = Math.atan2(@floor_height, total_run) * (180.0 / Math::PI)

      {
        num_risers: num_risers,
        num_treads: num_treads,
        rise_per_step: rise_per_step.round(3),
        run_per_step: run_per_step.round(3),
        total_rise: @floor_height.round(2),
        total_run: total_run.round(2),
        stringer_length: stringer_length.round(2),
        angle: angle.round(2)
      }
    end

    private

    def validate!
      @errors << "Floor height must be greater than zero" unless @floor_height.positive?
      if @run_preference && @run_preference > 0 && @run_preference < MIN_TREAD_DEPTH
        @errors << "Run preference must be at least #{MIN_TREAD_DEPTH} inches (IRC minimum)"
      end
    end
  end
end
