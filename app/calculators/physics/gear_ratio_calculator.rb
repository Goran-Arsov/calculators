module Physics
  class GearRatioCalculator
    attr_reader :errors

    def initialize(driving_teeth:, driven_teeth:, input_speed: nil, input_torque: nil)
      @driving_teeth = driving_teeth.to_f
      @driven_teeth = driven_teeth.to_f
      @input_speed = input_speed.present? ? input_speed.to_f : nil
      @input_torque = input_torque.present? ? input_torque.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gear_ratio = @driven_teeth / @driving_teeth
      mechanical_advantage = gear_ratio

      result = {
        valid: true,
        driving_teeth: @driving_teeth.to_i,
        driven_teeth: @driven_teeth.to_i,
        gear_ratio: gear_ratio.round(4),
        gear_ratio_display: format_ratio(gear_ratio),
        mechanical_advantage: mechanical_advantage.round(4),
        speed_reduction: gear_ratio > 1,
        torque_multiplication: gear_ratio > 1
      }

      if @input_speed
        output_speed = @input_speed / gear_ratio
        result[:input_speed_rpm] = @input_speed.round(2)
        result[:output_speed_rpm] = output_speed.round(2)
      end

      if @input_torque
        output_torque = @input_torque * gear_ratio
        result[:input_torque_nm] = @input_torque.round(2)
        result[:output_torque_nm] = output_torque.round(2)
        result[:torque_multiplier] = gear_ratio.round(4)
      end

      result
    end

    private

    def validate!
      if @driving_teeth <= 0
        @errors << "Driving gear teeth must be a positive number"
      end

      if @driven_teeth <= 0
        @errors << "Driven gear teeth must be a positive number"
      end

      if @driving_teeth > 0 && @driving_teeth != @driving_teeth.to_i.to_f
        @errors << "Driving gear teeth must be a whole number"
      end

      if @driven_teeth > 0 && @driven_teeth != @driven_teeth.to_i.to_f
        @errors << "Driven gear teeth must be a whole number"
      end

      if @input_speed && @input_speed < 0
        @errors << "Input speed must be non-negative"
      end

      if @input_torque && @input_torque < 0
        @errors << "Input torque must be non-negative"
      end
    end

    def format_ratio(ratio)
      if ratio >= 1
        "#{ratio.round(2)}:1"
      else
        "1:#{(1.0 / ratio).round(2)}"
      end
    end
  end
end
