module Physics
  class ProjectileMotionCalculator
    GRAVITY = 9.80665

    attr_reader :errors

    def initialize(velocity:, angle:, height: 0)
      @velocity = velocity.to_f
      @angle = angle.to_f
      @height = height.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      angle_rad = @angle * ::Math::PI / 180.0
      vx = @velocity * ::Math.cos(angle_rad)
      vy = @velocity * ::Math.sin(angle_rad)

      # Time to reach max height
      t_peak = vy / GRAVITY
      max_height = @height + (vy**2) / (2 * GRAVITY)

      # Total flight time (quadratic: -0.5g*t^2 + vy*t + h = 0)
      discriminant = vy**2 + 2 * GRAVITY * @height
      total_time = (vy + ::Math.sqrt(discriminant)) / GRAVITY

      range = vx * total_time

      {
        valid: true,
        range: range.round(4),
        max_height: max_height.round(4),
        flight_time: total_time.round(4),
        time_to_peak: t_peak.round(4),
        horizontal_velocity: vx.round(4),
        vertical_velocity: vy.round(4)
      }
    end

    private

    def validate!
      @errors << "Velocity must be positive" if @velocity <= 0
      @errors << "Angle must be between 0 and 90 degrees" if @angle <= 0 || @angle >= 90
      @errors << "Height must be non-negative" if @height < 0
    end
  end
end
