module Physics
  class SpringConstantCalculator
    attr_reader :errors

    def initialize(mode:, force: nil, displacement: nil, mass: nil, period: nil)
      @mode = mode.to_s.downcase.strip
      @force = force.present? ? force.to_f : nil
      @displacement = displacement.present? ? displacement.to_f : nil
      @mass = mass.present? ? mass.to_f : nil
      @period = period.present? ? period.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "hookes_law"
        calculate_from_hookes_law
      when "oscillation"
        calculate_from_oscillation
      end
    end

    private

    def calculate_from_hookes_law
      # Hooke's Law: F = k * x => k = F / x
      k = @force.abs / @displacement.abs
      pe = 0.5 * k * @displacement**2

      {
        valid: true,
        mode: "hookes_law",
        mode_label: "Hooke's Law (F = kx)",
        force_n: @force.round(4),
        displacement_m: @displacement.round(4),
        spring_constant_n_m: k.round(4),
        potential_energy_j: pe.round(4),
        frequency_hz: calculate_frequency_from_k(k),
        description: "Spring constant calculated from force and displacement"
      }
    end

    def calculate_from_oscillation
      # Period of a mass-spring system: T = 2*pi*sqrt(m/k) => k = (2*pi/T)^2 * m
      k = (2.0 * ::Math::PI / @period)**2 * @mass
      frequency = 1.0 / @period
      angular_frequency = 2.0 * ::Math::PI * frequency

      {
        valid: true,
        mode: "oscillation",
        mode_label: "Mass-Spring Oscillation (T = 2\u03C0\u221A(m/k))",
        mass_kg: @mass.round(4),
        period_s: @period.round(4),
        spring_constant_n_m: k.round(4),
        frequency_hz: frequency.round(4),
        angular_frequency_rad_s: angular_frequency.round(4),
        description: "Spring constant calculated from mass and period of oscillation"
      }
    end

    def calculate_frequency_from_k(k)
      # Without mass, we cannot determine frequency from k alone
      # Return nil if no mass context
      nil
    end

    def validate!
      unless %w[hookes_law oscillation].include?(@mode)
        @errors << "Mode must be 'hookes_law' or 'oscillation'"
        return
      end

      if @mode == "hookes_law"
        if @force.nil?
          @errors << "Force is required for Hooke's Law calculation"
        elsif @force == 0
          @errors << "Force must be non-zero"
        end

        if @displacement.nil?
          @errors << "Displacement is required for Hooke's Law calculation"
        elsif @displacement == 0
          @errors << "Displacement must be non-zero"
        end
      end

      if @mode == "oscillation"
        if @mass.nil?
          @errors << "Mass is required for oscillation calculation"
        elsif @mass <= 0
          @errors << "Mass must be a positive number"
        end

        if @period.nil?
          @errors << "Period is required for oscillation calculation"
        elsif @period <= 0
          @errors << "Period must be a positive number"
        end
      end
    end
  end
end
