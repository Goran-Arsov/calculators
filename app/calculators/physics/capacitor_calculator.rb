module Physics
  class CapacitorCalculator
    attr_reader :errors

    VALID_MODES = %w[basic series parallel].freeze

    def initialize(mode:, capacitance: nil, voltage: nil, charge: nil, capacitances: nil)
      @mode = mode.to_s.downcase.strip
      @capacitance = capacitance.present? ? capacitance.to_f : nil
      @voltage = voltage.present? ? voltage.to_f : nil
      @charge = charge.present? ? charge.to_f : nil
      @capacitances = parse_capacitances(capacitances)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "basic"
        calculate_basic
      when "series"
        calculate_series
      when "parallel"
        calculate_parallel
      end
    end

    private

    def calculate_basic
      # C = Q/V, E = 1/2 * C * V^2
      # Calculate the missing value from the two provided
      if @capacitance && @voltage
        charge = @capacitance * @voltage
        energy = 0.5 * @capacitance * @voltage**2
        cap = @capacitance
        volt = @voltage
      elsif @charge && @voltage
        cap = @charge / @voltage
        energy = 0.5 * cap * @voltage**2
        charge = @charge
        volt = @voltage
      elsif @charge && @capacitance
        volt = @charge / @capacitance
        energy = 0.5 * @capacitance * volt**2
        charge = @charge
        cap = @capacitance
      end

      {
        valid: true,
        mode: "basic",
        capacitance_f: cap.round(10),
        capacitance_uf: (cap * 1e6).round(4),
        voltage_v: volt.round(4),
        charge_c: charge.round(10),
        charge_uc: (charge * 1e6).round(4),
        energy_j: energy.round(10),
        energy_uj: (energy * 1e6).round(4)
      }
    end

    def calculate_series
      # Series: 1/Ct = sum(1/Ci)
      inv_total = @capacitances.sum { |c| 1.0 / c }
      total_capacitance = 1.0 / inv_total

      {
        valid: true,
        mode: "series",
        capacitances_f: @capacitances.map { |c| c.round(10) },
        capacitances_uf: @capacitances.map { |c| (c * 1e6).round(4) },
        total_capacitance_f: total_capacitance.round(10),
        total_capacitance_uf: (total_capacitance * 1e6).round(4),
        count: @capacitances.length
      }
    end

    def calculate_parallel
      # Parallel: Ct = sum(Ci)
      total_capacitance = @capacitances.sum

      {
        valid: true,
        mode: "parallel",
        capacitances_f: @capacitances.map { |c| c.round(10) },
        capacitances_uf: @capacitances.map { |c| (c * 1e6).round(4) },
        total_capacitance_f: total_capacitance.round(10),
        total_capacitance_uf: (total_capacitance * 1e6).round(4),
        count: @capacitances.length
      }
    end

    def parse_capacitances(input)
      return [] if input.blank?

      if input.is_a?(Array)
        input.map(&:to_f).reject(&:zero?)
      else
        input.to_s.split(",").map(&:strip).reject(&:blank?).map(&:to_f).reject(&:zero?)
      end
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'basic', 'series', or 'parallel'"
        return
      end

      case @mode
      when "basic"
        validate_basic_inputs
      when "series", "parallel"
        if @capacitances.length < 2
          @errors << "At least two capacitance values are required for #{@mode} calculation"
        end
        @capacitances.each_with_index do |c, i|
          if c <= 0
            @errors << "Capacitance #{i + 1} must be a positive number"
          end
        end
      end
    end

    def validate_basic_inputs
      provided = []
      provided << :capacitance if @capacitance
      provided << :voltage if @voltage
      provided << :charge if @charge

      if provided.length < 2
        @errors << "At least two of capacitance, voltage, and charge are required"
        return
      end

      if @capacitance && @capacitance <= 0
        @errors << "Capacitance must be a positive number"
      end

      if @voltage && @voltage == 0
        @errors << "Voltage must be non-zero"
      end

      if @charge && @charge <= 0
        @errors << "Charge must be a positive number"
      end
    end
  end
end
