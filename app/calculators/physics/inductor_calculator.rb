# frozen_string_literal: true

module Physics
  class InductorCalculator
    attr_reader :errors

    VALID_MODES = %w[basic series parallel time_constant].freeze

    def initialize(mode:, inductance: nil, current: nil, resistance: nil, inductances: nil)
      @mode = mode.to_s.downcase.strip
      @inductance = inductance.present? ? inductance.to_f : nil
      @current = current.present? ? current.to_f : nil
      @resistance = resistance.present? ? resistance.to_f : nil
      @inductances = parse_inductances(inductances)
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
      when "time_constant"
        calculate_time_constant
      end
    end

    private

    def calculate_basic
      # Energy stored: E = 1/2 * L * I^2
      energy = 0.5 * @inductance * @current**2

      {
        valid: true,
        mode: "basic",
        inductance_h: @inductance.round(8),
        inductance_mh: (@inductance * 1e3).round(4),
        inductance_uh: (@inductance * 1e6).round(4),
        current_a: @current.round(4),
        energy_j: energy.round(8),
        energy_mj: (energy * 1e3).round(4)
      }
    end

    def calculate_series
      # Series: Lt = sum(Li)
      total_inductance = @inductances.sum

      {
        valid: true,
        mode: "series",
        inductances_h: @inductances.map { |l| l.round(8) },
        inductances_mh: @inductances.map { |l| (l * 1e3).round(4) },
        total_inductance_h: total_inductance.round(8),
        total_inductance_mh: (total_inductance * 1e3).round(4),
        count: @inductances.length
      }
    end

    def calculate_parallel
      # Parallel: 1/Lt = sum(1/Li)
      inv_total = @inductances.sum { |l| 1.0 / l }
      total_inductance = 1.0 / inv_total

      {
        valid: true,
        mode: "parallel",
        inductances_h: @inductances.map { |l| l.round(8) },
        inductances_mh: @inductances.map { |l| (l * 1e3).round(4) },
        total_inductance_h: total_inductance.round(8),
        total_inductance_mh: (total_inductance * 1e3).round(4),
        count: @inductances.length
      }
    end

    def calculate_time_constant
      # Time constant: tau = L / R
      tau = @inductance / @resistance

      # Time to reach ~63.2% of final value (1 tau)
      # Time to reach ~95% (3 tau)
      # Time to reach ~99.3% (5 tau)
      tau_1 = tau
      tau_3 = 3.0 * tau
      tau_5 = 5.0 * tau

      {
        valid: true,
        mode: "time_constant",
        inductance_h: @inductance.round(8),
        inductance_mh: (@inductance * 1e3).round(4),
        resistance_ohm: @resistance.round(4),
        time_constant_s: tau.round(8),
        time_constant_ms: (tau * 1e3).round(4),
        time_to_63_percent_s: tau_1.round(8),
        time_to_95_percent_s: tau_3.round(8),
        time_to_99_percent_s: tau_5.round(8)
      }
    end

    def parse_inductances(input)
      return [] if input.blank?

      if input.is_a?(Array)
        input.map(&:to_f).reject(&:zero?)
      else
        input.to_s.split(",").map(&:strip).reject(&:blank?).map(&:to_f).reject(&:zero?)
      end
    end

    def validate!
      unless VALID_MODES.include?(@mode)
        @errors << "Mode must be 'basic', 'series', 'parallel', or 'time_constant'"
        return
      end

      case @mode
      when "basic"
        validate_positive(@inductance, "Inductance")
        validate_required(@current, "Current")
      when "series", "parallel"
        if @inductances.length < 2
          @errors << "At least two inductance values are required for #{@mode} calculation"
        end
        @inductances.each_with_index do |l, i|
          if l <= 0
            @errors << "Inductance #{i + 1} must be a positive number"
          end
        end
      when "time_constant"
        validate_positive(@inductance, "Inductance")
        validate_positive(@resistance, "Resistance")
      end
    end

    def validate_positive(value, label)
      if value.nil?
        @errors << "#{label} is required"
      elsif value <= 0
        @errors << "#{label} must be a positive number"
      end
    end

    def validate_required(value, label)
      @errors << "#{label} is required" if value.nil?
    end
  end
end
