# frozen_string_literal: true

module Construction
  class DrainageSlopeCalculator
    attr_reader :errors

    # Minimum slope requirements by pipe diameter (inches per foot)
    MINIMUM_SLOPES = {
      2 => { slope_in_per_ft: 0.25, slope_pct: 2.08, label: "2-inch pipe" },
      3 => { slope_in_per_ft: 0.25, slope_pct: 2.08, label: "3-inch pipe" },
      4 => { slope_in_per_ft: 0.125, slope_pct: 1.04, label: "4-inch pipe" },
      6 => { slope_in_per_ft: 0.125, slope_pct: 1.04, label: "6-inch pipe" },
      8 => { slope_in_per_ft: 0.0625, slope_pct: 0.52, label: "8-inch pipe" }
    }.freeze

    INCHES_PER_FOOT = 12.0

    def initialize(run_length_ft:, pipe_diameter_in: 4, slope_pct: nil)
      @run_length_ft = run_length_ft.to_f
      @pipe_diameter_in = pipe_diameter_in.to_i
      @custom_slope_pct = slope_pct.nil? || slope_pct.to_s.strip.empty? ? nil : slope_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pipe_spec = MINIMUM_SLOPES[@pipe_diameter_in]

      # Use custom slope or minimum required slope
      if @custom_slope_pct
        slope_pct = @custom_slope_pct
      else
        slope_pct = pipe_spec[:slope_pct]
      end

      slope_in_per_ft = (slope_pct / 100.0) * INCHES_PER_FOOT
      total_drop_in = (slope_in_per_ft * @run_length_ft).round(2)
      total_drop_ft = (total_drop_in / INCHES_PER_FOOT).round(3)

      meets_minimum = slope_pct >= pipe_spec[:slope_pct]
      minimum_slope_pct = pipe_spec[:slope_pct]
      minimum_drop_in_per_ft = pipe_spec[:slope_in_per_ft]

      # Velocity estimate using Manning's equation simplified
      # V = (1.486/n) * R^(2/3) * S^(1/2) for full pipe
      # Using n=0.013 for PVC, R = D/4
      n = 0.013
      radius_ft = (@pipe_diameter_in / 2.0) / INCHES_PER_FOOT
      hydraulic_radius = radius_ft / 2.0  # R = D/4 for full pipe
      slope_decimal = slope_pct / 100.0
      velocity_fps = ((1.486 / n) * (hydraulic_radius**(2.0 / 3.0)) * (slope_decimal**0.5)).round(2)

      {
        valid: true,
        pipe_diameter_in: @pipe_diameter_in,
        run_length_ft: @run_length_ft,
        slope_pct: slope_pct.round(2),
        slope_in_per_ft: slope_in_per_ft.round(3),
        total_drop_in: total_drop_in,
        total_drop_ft: total_drop_ft,
        meets_minimum: meets_minimum,
        minimum_slope_pct: minimum_slope_pct,
        minimum_drop_in_per_ft: minimum_drop_in_per_ft,
        estimated_velocity_fps: velocity_fps
      }
    end

    private

    def validate!
      @errors << "Run length must be greater than zero" unless @run_length_ft.positive?
      @errors << "Pipe diameter must be one of: #{MINIMUM_SLOPES.keys.join(', ')} inches" unless MINIMUM_SLOPES.key?(@pipe_diameter_in)
      @errors << "Slope percentage must be positive" if @custom_slope_pct && !@custom_slope_pct.positive?
    end
  end
end
