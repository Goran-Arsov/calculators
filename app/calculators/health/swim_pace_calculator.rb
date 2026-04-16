# frozen_string_literal: true

module Health
  class SwimPaceCalculator
    attr_reader :errors

    # Standard swim distances
    DISTANCES = {
      "50" => 50,
      "100" => 100,
      "200" => 200,
      "400" => 400,
      "800" => 800,
      "1500" => 1500,
      "1650" => 1650 # mile in yards
    }.freeze

    POOL_UNITS = %w[meters yards].freeze

    def initialize(distance:, time_seconds:, pool_unit: "meters")
      @distance = distance.to_f
      @time_seconds = time_seconds.to_f
      @pool_unit = pool_unit.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pace_per_100 = (@time_seconds / @distance) * 100
      speed_per_hour = (@distance / @time_seconds) * 3600

      # Convert between meters and yards
      if @pool_unit == "meters"
        distance_yards = @distance * 1.09361
        pace_per_100y = pace_per_100 / 1.09361
      else
        distance_yards = @distance
        pace_per_100y = pace_per_100
        pace_per_100 = pace_per_100 * 1.09361 # convert to per 100m
      end

      # Estimate times for standard distances
      estimated_times = estimate_times(pace_per_100)

      {
        valid: true,
        distance: @distance,
        pool_unit: @pool_unit,
        time_seconds: @time_seconds,
        time_formatted: format_time(@time_seconds),
        pace_per_100m_seconds: pace_per_100.round(1),
        pace_per_100m_formatted: format_pace(pace_per_100),
        pace_per_100y_seconds: pace_per_100y.round(1),
        pace_per_100y_formatted: format_pace(pace_per_100y),
        speed_per_hour: speed_per_hour.round(0),
        speed_km_per_hour: (speed_per_hour / 1000.0).round(2),
        estimated_times: estimated_times,
        css_pace: calculate_css_pace(pace_per_100)
      }
    end

    private

    def estimate_times(base_pace_per_100m)
      # Apply a fatigue factor for longer distances
      targets = [
        { label: "50m", distance: 50, factor: 0.92 },
        { label: "100m", distance: 100, factor: 0.95 },
        { label: "200m", distance: 200, factor: 0.97 },
        { label: "400m", distance: 400, factor: 1.0 },
        { label: "800m", distance: 800, factor: 1.03 },
        { label: "1500m", distance: 1500, factor: 1.06 },
        { label: "1 mile (1650y)", distance: 1609.34, factor: 1.07 }
      ]

      targets.map do |t|
        adjusted_pace = base_pace_per_100m * t[:factor]
        estimated_seconds = (adjusted_pace / 100.0) * t[:distance]
        {
          label: t[:label],
          distance: t[:distance],
          estimated_seconds: estimated_seconds.round(0).to_i,
          estimated_formatted: format_time(estimated_seconds),
          pace_per_100m: format_pace(adjusted_pace)
        }
      end
    end

    def calculate_css_pace(pace_per_100m)
      # Critical Swim Speed: approximate as ~5% slower than 400m pace
      css = pace_per_100m * 1.05
      {
        seconds_per_100m: css.round(1),
        formatted: format_pace(css),
        description: "Approximate threshold pace for aerobic training sets"
      }
    end

    def format_pace(seconds)
      minutes = (seconds / 60).floor
      secs = (seconds % 60).round
      if secs == 60
        minutes += 1
        secs = 0
      end
      format("%d:%02d", minutes, secs)
    end

    def format_time(total_seconds)
      total_seconds = total_seconds.round
      hours = total_seconds / 3600
      minutes = (total_seconds % 3600) / 60
      seconds = total_seconds % 60

      if hours > 0
        format("%d:%02d:%02d", hours, minutes, seconds)
      else
        format("%d:%02d", minutes, seconds)
      end
    end

    def validate!
      @errors << "Distance must be positive" unless @distance > 0
      @errors << "Distance seems unrealistically high (max 10000)" if @distance > 10000
      @errors << "Time must be positive" unless @time_seconds > 0
      @errors << "Time seems unrealistically high (max 24 hours)" if @time_seconds > 86400
      unless POOL_UNITS.include?(@pool_unit)
        @errors << "Pool unit must be meters or yards"
      end
    end
  end
end
