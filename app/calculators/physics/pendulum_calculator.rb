module Physics
  class PendulumCalculator
    attr_reader :errors

    VALID_MODES = %w[find_period find_length find_gravity].freeze
    DEFAULT_GRAVITY = 9.80665

    def initialize(mode:, length: nil, gravity: nil, period: nil)
      @mode = mode.to_s.downcase.strip
      @length = length.present? ? length.to_f : nil
      @gravity = gravity.present? ? gravity.to_f : nil
      @period = period.present? ? period.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "find_period"
        calculate_period
      when "find_length"
        calculate_length
      when "find_gravity"
        calculate_gravity
      end
    end

    private

    def calculate_period
      g = @gravity || DEFAULT_GRAVITY
      # T = 2*pi*sqrt(L/g)
      period = 2.0 * ::Math::PI * ::Math.sqrt(@length / g)
      frequency = 1.0 / period
      angular_frequency = 2.0 * ::Math::PI * frequency

      build_result(
        length: @length,
        gravity: g,
        period: period,
        frequency: frequency,
        angular_frequency: angular_frequency
      )
    end

    def calculate_length
      g = @gravity || DEFAULT_GRAVITY
      # T = 2*pi*sqrt(L/g) => L = g*(T/(2*pi))^2
      length = g * (@period / (2.0 * ::Math::PI))**2
      frequency = 1.0 / @period
      angular_frequency = 2.0 * ::Math::PI * frequency

      build_result(
        length: length,
        gravity: g,
        period: @period,
        frequency: frequency,
        angular_frequency: angular_frequency
      )
    end

    def calculate_gravity
      # T = 2*pi*sqrt(L/g) => g = L*(2*pi/T)^2
      gravity = @length * (2.0 * ::Math::PI / @period)**2
      frequency = 1.0 / @period
      angular_frequency = 2.0 * ::Math::PI * frequency

      build_result(
        length: @length,
        gravity: gravity,
        period: @period,
        frequency: frequency,
        angular_frequency: angular_frequency
      )
    end

    def build_result(length:, gravity:, period:, frequency:, angular_frequency:)
      {
        valid: true,
        mode: @mode,
        length_m: length.round(6),
        gravity_m_s2: gravity.round(4),
        period_s: period.round(6),
        frequency_hz: frequency.round(6),
        angular_frequency_rad_s: angular_frequency.round(6)
      }
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'find_period', 'find_length', or 'find_gravity'"
        return
      end

      case @mode
      when "find_period"
        if @length.nil?
          @errors << "Length is required"
        elsif @length <= 0
          @errors << "Length must be a positive number"
        end
        validate_gravity_if_present
      when "find_length"
        if @period.nil?
          @errors << "Period is required"
        elsif @period <= 0
          @errors << "Period must be a positive number"
        end
        validate_gravity_if_present
      when "find_gravity"
        if @length.nil?
          @errors << "Length is required"
        elsif @length <= 0
          @errors << "Length must be a positive number"
        end
        if @period.nil?
          @errors << "Period is required"
        elsif @period <= 0
          @errors << "Period must be a positive number"
        end
      end
    end

    def validate_gravity_if_present
      return if @gravity.nil?

      if @gravity <= 0
        @errors << "Gravity must be a positive number"
      end
    end
  end
end
