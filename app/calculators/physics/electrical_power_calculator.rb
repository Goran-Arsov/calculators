# frozen_string_literal: true

module Physics
  class ElectricalPowerCalculator
    attr_reader :errors

    VALID_MODES = %w[p_iv p_i2r p_v2r find_current find_voltage find_resistance].freeze

    def initialize(mode:, power: nil, voltage: nil, current: nil, resistance: nil)
      @mode = mode.to_s.downcase.strip
      @power = power.present? ? power.to_f : nil
      @voltage = voltage.present? ? voltage.to_f : nil
      @current = current.present? ? current.to_f : nil
      @resistance = resistance.present? ? resistance.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "p_iv"
        calculate_p_iv
      when "p_i2r"
        calculate_p_i2r
      when "p_v2r"
        calculate_p_v2r
      when "find_current"
        calculate_find_current
      when "find_voltage"
        calculate_find_voltage
      when "find_resistance"
        calculate_find_resistance
      end
    end

    private

    def calculate_p_iv
      # P = I * V
      power = @current * @voltage
      resistance = @voltage / @current if @current != 0
      energy_1h = power * 3600.0 # joules in 1 hour

      build_result(
        power: power,
        voltage: @voltage,
        current: @current,
        resistance: resistance,
        energy_1h: energy_1h
      )
    end

    def calculate_p_i2r
      # P = I^2 * R
      power = @current**2 * @resistance
      voltage = @current * @resistance
      energy_1h = power * 3600.0

      build_result(
        power: power,
        voltage: voltage,
        current: @current,
        resistance: @resistance,
        energy_1h: energy_1h
      )
    end

    def calculate_p_v2r
      # P = V^2 / R
      power = @voltage**2 / @resistance
      current = @voltage / @resistance
      energy_1h = power * 3600.0

      build_result(
        power: power,
        voltage: @voltage,
        current: current,
        resistance: @resistance,
        energy_1h: energy_1h
      )
    end

    def calculate_find_current
      # I = P / V
      current = @power / @voltage
      resistance = @voltage / current if current != 0
      energy_1h = @power * 3600.0

      build_result(
        power: @power,
        voltage: @voltage,
        current: current,
        resistance: resistance,
        energy_1h: energy_1h
      )
    end

    def calculate_find_voltage
      # V = P / I
      voltage = @power / @current
      resistance = voltage / @current if @current != 0
      energy_1h = @power * 3600.0

      build_result(
        power: @power,
        voltage: voltage,
        current: @current,
        resistance: resistance,
        energy_1h: energy_1h
      )
    end

    def calculate_find_resistance
      # R = V^2 / P
      resistance = @voltage**2 / @power
      current = @power / @voltage
      energy_1h = @power * 3600.0

      build_result(
        power: @power,
        voltage: @voltage,
        current: current,
        resistance: resistance,
        energy_1h: energy_1h
      )
    end

    def build_result(power:, voltage:, current:, resistance:, energy_1h:)
      kwh = power / 1000.0 # kilowatts

      {
        valid: true,
        mode: @mode,
        power_w: power.round(4),
        power_kw: kwh.round(6),
        voltage_v: voltage&.round(4),
        current_a: current.round(4),
        resistance_ohm: resistance&.round(4),
        energy_j_per_hour: energy_1h.round(2),
        energy_kwh: (kwh).round(6)
      }
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be one of: #{VALID_MODES.join(', ')}"
        return
      end

      case @mode
      when "p_iv"
        validate_required(@current, "Current")
        validate_required(@voltage, "Voltage")
        validate_nonzero(@current, "Current")
      when "p_i2r"
        validate_required(@current, "Current")
        validate_required(@resistance, "Resistance")
        validate_positive(@resistance, "Resistance")
      when "p_v2r"
        validate_required(@voltage, "Voltage")
        validate_required(@resistance, "Resistance")
        validate_positive(@resistance, "Resistance")
      when "find_current"
        validate_required(@power, "Power")
        validate_required(@voltage, "Voltage")
        validate_nonzero(@voltage, "Voltage")
      when "find_voltage"
        validate_required(@power, "Power")
        validate_required(@current, "Current")
        validate_nonzero(@current, "Current")
      when "find_resistance"
        validate_required(@power, "Power")
        validate_required(@voltage, "Voltage")
        validate_nonzero(@power, "Power")
      end
    end

    def validate_required(value, label)
      @errors << "#{label} is required" if value.nil?
    end

    def validate_positive(value, label)
      return if value.nil?
      @errors << "#{label} must be a positive number" if value <= 0
    end

    def validate_nonzero(value, label)
      return if value.nil?
      @errors << "#{label} must be non-zero" if value == 0
    end
  end
end
