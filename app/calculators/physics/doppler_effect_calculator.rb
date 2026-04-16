# frozen_string_literal: true

module Physics
  class DopplerEffectCalculator
    attr_reader :errors

    DEFAULT_SPEED_OF_SOUND = 343.0 # m/s at 20C in air

    def initialize(source_frequency:, source_speed: nil, observer_speed: nil, speed_of_sound: nil,
                   source_moving_toward: true, observer_moving_toward: true)
      @source_frequency = source_frequency.present? ? source_frequency.to_f : nil
      @source_speed = source_speed.present? ? source_speed.to_f : 0.0
      @observer_speed = observer_speed.present? ? observer_speed.to_f : 0.0
      @speed_of_sound = speed_of_sound.present? ? speed_of_sound.to_f : DEFAULT_SPEED_OF_SOUND
      @source_moving_toward = source_moving_toward.to_s == "true"
      @observer_moving_toward = observer_moving_toward.to_s == "true"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Doppler effect formula:
      # f' = f * (v +/- v_observer) / (v -/+ v_source)
      # + v_observer when observer moves toward source
      # - v_observer when observer moves away from source
      # - v_source when source moves toward observer
      # + v_source when source moves away from observer

      v_obs_sign = @observer_moving_toward ? 1.0 : -1.0
      v_src_sign = @source_moving_toward ? -1.0 : 1.0

      numerator = @speed_of_sound + (v_obs_sign * @observer_speed)
      denominator = @speed_of_sound + (v_src_sign * @source_speed)

      if denominator <= 0
        @errors << "Source speed exceeds or equals the speed of sound (sonic boom condition)"
        return { valid: false, errors: @errors }
      end

      observed_frequency = @source_frequency * (numerator / denominator)
      frequency_shift = observed_frequency - @source_frequency
      percent_shift = (frequency_shift / @source_frequency) * 100.0

      # Wavelength calculations
      source_wavelength = @speed_of_sound / @source_frequency
      observed_wavelength = @speed_of_sound / observed_frequency

      shift_direction = if frequency_shift > 0.001
                          "Blueshift (higher frequency)"
      elsif frequency_shift < -0.001
                          "Redshift (lower frequency)"
      else
                          "No shift"
      end

      {
        valid: true,
        source_frequency_hz: @source_frequency.round(4),
        observed_frequency_hz: observed_frequency.round(4),
        frequency_shift_hz: frequency_shift.round(4),
        percent_shift: percent_shift.round(4),
        shift_direction: shift_direction,
        source_wavelength_m: source_wavelength.round(6),
        observed_wavelength_m: observed_wavelength.round(6),
        source_speed_m_s: @source_speed.round(2),
        observer_speed_m_s: @observer_speed.round(2),
        speed_of_sound_m_s: @speed_of_sound.round(2),
        source_moving_toward: @source_moving_toward,
        observer_moving_toward: @observer_moving_toward
      }
    end

    private

    def validate!
      if @source_frequency.nil?
        @errors << "Source frequency is required"
      elsif @source_frequency <= 0
        @errors << "Source frequency must be a positive number"
      end

      if @source_speed < 0
        @errors << "Source speed must be non-negative"
      end

      if @observer_speed < 0
        @errors << "Observer speed must be non-negative"
      end

      if @speed_of_sound <= 0
        @errors << "Speed of sound must be a positive number"
      end

      if @source_speed >= @speed_of_sound && @source_moving_toward
        @errors << "Source speed must be less than the speed of sound for approach"
      end
    end
  end
end
