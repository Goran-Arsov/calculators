module Physics
  class CentripetalForceCalculator
    attr_reader :errors

    VALID_MODES = %w[find_force find_mass find_velocity find_radius].freeze

    def initialize(mode:, force: nil, mass: nil, velocity: nil, radius: nil)
      @mode = mode.to_s.downcase.strip
      @force = force.present? ? force.to_f : nil
      @mass = mass.present? ? mass.to_f : nil
      @velocity = velocity.present? ? velocity.to_f : nil
      @radius = radius.present? ? radius.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_force"
        calculate_force
      when "find_mass"
        calculate_mass
      when "find_velocity"
        calculate_velocity
      when "find_radius"
        calculate_radius
      end
    end

    private

    def calculate_force
      # F = mv^2/r
      force = @mass * @velocity**2 / @radius
      centripetal_acceleration = @velocity**2 / @radius
      angular_velocity = @velocity / @radius
      period = 2.0 * ::Math::PI * @radius / @velocity

      build_result(
        force: force,
        mass: @mass,
        velocity: @velocity,
        radius: @radius,
        centripetal_acceleration: centripetal_acceleration,
        angular_velocity: angular_velocity,
        period: period
      )
    end

    def calculate_mass
      # m = F*r/v^2
      mass = @force * @radius / @velocity**2
      centripetal_acceleration = @velocity**2 / @radius
      angular_velocity = @velocity / @radius
      period = 2.0 * ::Math::PI * @radius / @velocity

      build_result(
        force: @force,
        mass: mass,
        velocity: @velocity,
        radius: @radius,
        centripetal_acceleration: centripetal_acceleration,
        angular_velocity: angular_velocity,
        period: period
      )
    end

    def calculate_velocity
      # v = sqrt(F*r/m)
      velocity = ::Math.sqrt(@force * @radius / @mass)
      centripetal_acceleration = velocity**2 / @radius
      angular_velocity = velocity / @radius
      period = 2.0 * ::Math::PI * @radius / velocity

      build_result(
        force: @force,
        mass: @mass,
        velocity: velocity,
        radius: @radius,
        centripetal_acceleration: centripetal_acceleration,
        angular_velocity: angular_velocity,
        period: period
      )
    end

    def calculate_radius
      # r = mv^2/F
      radius = @mass * @velocity**2 / @force
      centripetal_acceleration = @velocity**2 / radius
      angular_velocity = @velocity / radius
      period = 2.0 * ::Math::PI * radius / @velocity

      build_result(
        force: @force,
        mass: @mass,
        velocity: @velocity,
        radius: radius,
        centripetal_acceleration: centripetal_acceleration,
        angular_velocity: angular_velocity,
        period: period
      )
    end

    def build_result(force:, mass:, velocity:, radius:, centripetal_acceleration:, angular_velocity:, period:)
      {
        valid: true,
        mode: @mode,
        force_n: force.round(4),
        mass_kg: mass.round(4),
        velocity_m_s: velocity.round(4),
        radius_m: radius.round(4),
        centripetal_acceleration_m_s2: centripetal_acceleration.round(4),
        angular_velocity_rad_s: angular_velocity.round(4),
        period_s: period.round(4)
      }
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'find_force', 'find_mass', 'find_velocity', or 'find_radius'"
        return
      end

      case @mode
      when "find_force"
        validate_positive(@mass, "Mass")
        validate_positive_nonzero(@velocity, "Velocity")
        validate_positive(@radius, "Radius")
      when "find_mass"
        validate_positive(@force, "Force")
        validate_positive_nonzero(@velocity, "Velocity")
        validate_positive(@radius, "Radius")
      when "find_velocity"
        validate_positive(@force, "Force")
        validate_positive(@mass, "Mass")
        validate_positive(@radius, "Radius")
      when "find_radius"
        validate_positive(@force, "Force")
        validate_positive(@mass, "Mass")
        validate_positive_nonzero(@velocity, "Velocity")
      end
    end

    def validate_positive(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value <= 0
        @errors << "#{label} must be a positive number"
      end
    end

    def validate_positive_nonzero(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value <= 0
        @errors << "#{label} must be a positive number"
      end
    end
  end
end
