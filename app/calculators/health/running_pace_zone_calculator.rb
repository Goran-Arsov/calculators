module Health
  class RunningPaceZoneCalculator
    attr_reader :errors

    # Zone definitions as percentage of threshold pace
    # Based on Jack Daniels VDOT-inspired system
    ZONES = {
      zone_1: { name: "Easy / Recovery", min_pct: 125, max_pct: 140, description: "Easy conversational pace for recovery and base building" },
      zone_2: { name: "Aerobic / Endurance", min_pct: 110, max_pct: 125, description: "Steady-state aerobic running for endurance development" },
      zone_3: { name: "Tempo / Threshold", min_pct: 97, max_pct: 110, description: "Comfortably hard pace at or near lactate threshold" },
      zone_4: { name: "VO2max / Interval", min_pct: 88, max_pct: 97, description: "Hard intervals to improve maximal oxygen uptake" },
      zone_5: { name: "Speed / Repetition", min_pct: 78, max_pct: 88, description: "Near-sprint repeats for speed and running economy" }
    }.freeze

    # Common race distances in km
    RACE_DISTANCES = {
      "5k" => 5.0,
      "10k" => 10.0,
      "half_marathon" => 21.0975,
      "marathon" => 42.195
    }.freeze

    def initialize(mode:, threshold_pace_seconds: nil, race_distance: nil, race_time_seconds: nil)
      @mode = mode.to_s
      @threshold_pace_seconds = threshold_pace_seconds&.to_f
      @race_distance = race_distance.to_s
      @race_time_seconds = race_time_seconds&.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      threshold_pace = calculate_threshold_pace

      zones = ZONES.map do |key, zone|
        # Higher percentage = slower pace (e.g., 140% of threshold is slower)
        min_pace = (threshold_pace * zone[:min_pct] / 100.0).round(0)
        max_pace = (threshold_pace * zone[:max_pct] / 100.0).round(0)
        # For display, min_pace is the faster end (lower number), max_pace is slower
        {
          key: key,
          name: zone[:name],
          description: zone[:description],
          min_pace_seconds: [ min_pace, max_pace ].min.to_i,
          max_pace_seconds: [ min_pace, max_pace ].max.to_i,
          min_pace_formatted: format_pace([ min_pace, max_pace ].min),
          max_pace_formatted: format_pace([ min_pace, max_pace ].max)
        }
      end

      result = {
        valid: true,
        threshold_pace_seconds: threshold_pace.round(0).to_i,
        threshold_pace_formatted: format_pace(threshold_pace),
        zones: zones
      }

      if @mode == "race"
        distance_km = RACE_DISTANCES[@race_distance]
        race_pace = @race_time_seconds / distance_km
        result[:race_distance] = @race_distance
        result[:race_time_formatted] = format_time(@race_time_seconds)
        result[:race_pace_seconds] = race_pace.round(0).to_i
        result[:race_pace_formatted] = format_pace(race_pace)
      end

      result
    end

    private

    def calculate_threshold_pace
      if @mode == "threshold"
        @threshold_pace_seconds
      else
        # Estimate threshold pace from race time
        # The relationship varies by distance
        distance_km = RACE_DISTANCES[@race_distance]
        race_pace = @race_time_seconds / distance_km

        # Approximate conversion factors to threshold pace
        case @race_distance
        when "5k"
          race_pace * 1.06 # 5K pace is roughly 94% of threshold
        when "10k"
          race_pace * 1.02 # 10K pace is close to threshold
        when "half_marathon"
          race_pace * 0.96 # Half marathon pace is slightly slower than threshold
        when "marathon"
          race_pace * 0.89 # Marathon pace is about 89% of threshold
        end
      end
    end

    def format_pace(seconds_per_km)
      total_seconds = seconds_per_km.round
      minutes = total_seconds / 60
      secs = total_seconds % 60
      format("%d:%02d /km", minutes, secs)
    end

    def format_time(total_seconds)
      hours = (total_seconds / 3600).floor
      minutes = ((total_seconds % 3600) / 60).floor
      seconds = (total_seconds % 60).round

      if hours > 0
        format("%d:%02d:%02d", hours, minutes, seconds)
      else
        format("%d:%02d", minutes, seconds)
      end
    end

    def validate!
      unless %w[threshold race].include?(@mode)
        @errors << "Mode must be 'threshold' or 'race'"
        return
      end

      if @mode == "threshold"
        if @threshold_pace_seconds.nil? || @threshold_pace_seconds <= 0
          @errors << "Threshold pace must be positive"
        elsif @threshold_pace_seconds > 900
          @errors << "Threshold pace seems too slow (max 15:00 /km)"
        end
      else
        unless RACE_DISTANCES.key?(@race_distance)
          @errors << "Race distance must be 5k, 10k, half_marathon, or marathon"
        end
        if @race_time_seconds.nil? || @race_time_seconds <= 0
          @errors << "Race time must be positive"
        end
      end
    end
  end
end
