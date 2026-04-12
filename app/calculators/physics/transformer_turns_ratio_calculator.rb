module Physics
  class TransformerTurnsRatioCalculator
    attr_reader :errors

    VALID_MODES = %w[find_output_voltage find_output_current find_turns_ratio find_turns].freeze

    def initialize(mode:, primary_voltage: nil, secondary_voltage: nil,
                   primary_current: nil, secondary_current: nil,
                   primary_turns: nil, secondary_turns: nil, efficiency: nil)
      @mode = mode.to_s.downcase.strip
      @primary_voltage = primary_voltage.present? ? primary_voltage.to_f : nil
      @secondary_voltage = secondary_voltage.present? ? secondary_voltage.to_f : nil
      @primary_current = primary_current.present? ? primary_current.to_f : nil
      @secondary_current = secondary_current.present? ? secondary_current.to_f : nil
      @primary_turns = primary_turns.present? ? primary_turns.to_f : nil
      @secondary_turns = secondary_turns.present? ? secondary_turns.to_f : nil
      @efficiency = efficiency.present? ? efficiency.to_f / 100.0 : 1.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_output_voltage"
        calculate_output_voltage
      when "find_output_current"
        calculate_output_current
      when "find_turns_ratio"
        calculate_turns_ratio
      when "find_turns"
        calculate_turns
      end
    end

    private

    def calculate_output_voltage
      # V1/V2 = N1/N2 => V2 = V1 * N2/N1
      turns_ratio = @primary_turns / @secondary_turns
      secondary_voltage = @primary_voltage / turns_ratio

      # Power: P1 = V1 * I1 (if current given)
      primary_power = @primary_current ? @primary_voltage * @primary_current : nil
      secondary_power = primary_power ? primary_power * @efficiency : nil
      secondary_current = secondary_power ? secondary_power / secondary_voltage : nil

      build_result(
        primary_voltage: @primary_voltage,
        secondary_voltage: secondary_voltage,
        primary_turns: @primary_turns,
        secondary_turns: @secondary_turns,
        turns_ratio: turns_ratio,
        primary_current: @primary_current,
        secondary_current: secondary_current,
        primary_power: primary_power,
        secondary_power: secondary_power
      )
    end

    def calculate_output_current
      # Ideal transformer: V1*I1 = V2*I2 (with efficiency)
      # I2 = (V1 * I1 * efficiency) / V2
      primary_power = @primary_voltage * @primary_current
      secondary_power = primary_power * @efficiency
      secondary_current = secondary_power / @secondary_voltage

      turns_ratio = @primary_voltage / @secondary_voltage

      build_result(
        primary_voltage: @primary_voltage,
        secondary_voltage: @secondary_voltage,
        primary_turns: nil,
        secondary_turns: nil,
        turns_ratio: turns_ratio,
        primary_current: @primary_current,
        secondary_current: secondary_current,
        primary_power: primary_power,
        secondary_power: secondary_power
      )
    end

    def calculate_turns_ratio
      # Turns ratio = V1/V2 = N1/N2
      turns_ratio = @primary_voltage / @secondary_voltage

      primary_power = @primary_current ? @primary_voltage * @primary_current : nil
      secondary_power = primary_power ? primary_power * @efficiency : nil
      secondary_current = secondary_power ? secondary_power / @secondary_voltage : nil

      build_result(
        primary_voltage: @primary_voltage,
        secondary_voltage: @secondary_voltage,
        primary_turns: nil,
        secondary_turns: nil,
        turns_ratio: turns_ratio,
        primary_current: @primary_current,
        secondary_current: secondary_current,
        primary_power: primary_power,
        secondary_power: secondary_power
      )
    end

    def calculate_turns
      # N2 = N1 * V2/V1
      secondary_turns = @primary_turns * @secondary_voltage / @primary_voltage
      turns_ratio = @primary_voltage / @secondary_voltage

      primary_power = @primary_current ? @primary_voltage * @primary_current : nil
      secondary_power = primary_power ? primary_power * @efficiency : nil
      secondary_current = secondary_power ? secondary_power / @secondary_voltage : nil

      build_result(
        primary_voltage: @primary_voltage,
        secondary_voltage: @secondary_voltage,
        primary_turns: @primary_turns,
        secondary_turns: secondary_turns,
        turns_ratio: turns_ratio,
        primary_current: @primary_current,
        secondary_current: secondary_current,
        primary_power: primary_power,
        secondary_power: secondary_power
      )
    end

    def build_result(primary_voltage:, secondary_voltage:, primary_turns:, secondary_turns:,
                     turns_ratio:, primary_current:, secondary_current:, primary_power:, secondary_power:)
      transformer_type = if turns_ratio > 1.001
                           "Step-down"
                         elsif turns_ratio < 0.999
                           "Step-up"
                         else
                           "Isolation (1:1)"
                         end

      result = {
        valid: true,
        mode: @mode,
        primary_voltage_v: primary_voltage.round(4),
        secondary_voltage_v: secondary_voltage.round(4),
        turns_ratio: turns_ratio.round(6),
        turns_ratio_display: format_ratio(turns_ratio),
        transformer_type: transformer_type,
        efficiency_percent: (@efficiency * 100.0).round(2)
      }

      result[:primary_turns] = primary_turns.round(0) if primary_turns
      result[:secondary_turns] = secondary_turns.round(2) if secondary_turns
      result[:primary_current_a] = primary_current.round(4) if primary_current
      result[:secondary_current_a] = secondary_current.round(4) if secondary_current
      result[:primary_power_w] = primary_power.round(4) if primary_power
      result[:secondary_power_w] = secondary_power.round(4) if secondary_power

      result
    end

    def format_ratio(ratio)
      if ratio >= 1
        "#{ratio.round(2)}:1"
      else
        "1:#{(1.0 / ratio).round(2)}"
      end
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be one of: #{VALID_MODES.join(', ')}"
        return
      end

      if @efficiency <= 0 || @efficiency > 1.0
        @errors << "Efficiency must be between 0 and 100 percent"
      end

      case @mode
      when "find_output_voltage"
        validate_positive(@primary_voltage, "Primary voltage")
        validate_positive(@primary_turns, "Primary turns")
        validate_positive(@secondary_turns, "Secondary turns")
      when "find_output_current"
        validate_positive(@primary_voltage, "Primary voltage")
        validate_positive(@secondary_voltage, "Secondary voltage")
        validate_positive(@primary_current, "Primary current")
      when "find_turns_ratio"
        validate_positive(@primary_voltage, "Primary voltage")
        validate_positive(@secondary_voltage, "Secondary voltage")
      when "find_turns"
        validate_positive(@primary_voltage, "Primary voltage")
        validate_positive(@secondary_voltage, "Secondary voltage")
        validate_positive(@primary_turns, "Primary turns")
      end
    end

    def validate_positive(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value <= 0
        @errors << "#{label} must be a positive number"
      end
    end
  end
end
