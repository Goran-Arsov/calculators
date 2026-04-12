module Health
  class CaffeineHalfLifeCalculator
    attr_reader :errors

    HALF_LIFE_HOURS = 5.0
    DECAY_CONSTANT = Math.log(2) / HALF_LIFE_HOURS

    # Average caffeine content in mg for common sources
    CAFFEINE_SOURCES = {
      "coffee" => 95,
      "espresso" => 63,
      "black_tea" => 47,
      "green_tea" => 28,
      "energy_drink" => 80,
      "cola" => 34,
      "custom" => nil
    }.freeze

    SLEEP_THRESHOLD_MG = 50.0 # below this, caffeine unlikely to impair sleep

    def initialize(caffeine_mg:, hours_elapsed: nil, consumed_at: nil, sleep_time: nil)
      @caffeine_mg = caffeine_mg.to_f
      @hours_elapsed = hours_elapsed&.to_f
      @consumed_at = consumed_at.to_s.strip.presence
      @sleep_time = sleep_time.to_s.strip.presence
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      timeline = build_timeline
      sleep_safe_hours = hours_until_below(@caffeine_mg, SLEEP_THRESHOLD_MG)

      result = {
        valid: true,
        initial_caffeine_mg: @caffeine_mg,
        half_life_hours: HALF_LIFE_HOURS,
        sleep_threshold_mg: SLEEP_THRESHOLD_MG,
        hours_until_sleep_safe: sleep_safe_hours.round(1),
        timeline: timeline
      }

      if @hours_elapsed
        remaining = caffeine_remaining(@caffeine_mg, @hours_elapsed)
        result[:remaining_after_hours] = remaining.round(1)
        result[:hours_checked] = @hours_elapsed
        result[:percent_remaining] = ((remaining / @caffeine_mg) * 100).round(1)
      end

      if @consumed_at && @sleep_time
        consumed_hour = parse_time_to_hours(@consumed_at)
        sleep_hour = parse_time_to_hours(@sleep_time)
        hours_to_sleep = sleep_hour >= consumed_hour ? sleep_hour - consumed_hour : (24 - consumed_hour) + sleep_hour
        at_bedtime = caffeine_remaining(@caffeine_mg, hours_to_sleep)
        result[:caffeine_at_bedtime] = at_bedtime.round(1)
        result[:hours_to_sleep] = hours_to_sleep.round(1)
        result[:sleep_impact] = sleep_impact_label(at_bedtime)
      end

      if @consumed_at
        safe_hour = parse_time_to_hours(@consumed_at) + sleep_safe_hours
        safe_hour -= 24 if safe_hour >= 24
        result[:sleep_safe_time] = format_hour(safe_hour)
      end

      result
    end

    private

    def caffeine_remaining(initial, hours)
      initial * (0.5**(hours / HALF_LIFE_HOURS))
    end

    def hours_until_below(initial, threshold)
      return 0.0 if initial <= threshold

      # C(t) = C0 * 0.5^(t/5)
      # threshold = C0 * 0.5^(t/5)
      # t = 5 * log2(C0 / threshold)
      HALF_LIFE_HOURS * Math.log2(initial / threshold)
    end

    def build_timeline
      (0..24).step(1).map do |hour|
        remaining = caffeine_remaining(@caffeine_mg, hour)
        {
          hours: hour,
          caffeine_mg: remaining.round(1),
          percent: ((remaining / @caffeine_mg) * 100).round(1)
        }
      end
    end

    def parse_time_to_hours(time_str)
      parts = time_str.split(":")
      parts[0].to_f + parts[1].to_f / 60.0
    end

    def format_hour(decimal_hours)
      decimal_hours += 24 if decimal_hours < 0
      hours = decimal_hours.floor % 24
      minutes = ((decimal_hours - decimal_hours.floor) * 60).round
      if minutes == 60
        hours = (hours + 1) % 24
        minutes = 0
      end
      format("%02d:%02d", hours, minutes)
    end

    def sleep_impact_label(mg)
      if mg < 20
        "Minimal - unlikely to affect sleep"
      elsif mg < 50
        "Low - may slightly delay sleep onset"
      elsif mg < 100
        "Moderate - likely to impair sleep quality"
      else
        "High - significant sleep disruption expected"
      end
    end

    def validate!
      @errors << "Caffeine amount must be positive" unless @caffeine_mg > 0
      @errors << "Caffeine amount seems unrealistically high (max 2000 mg)" if @caffeine_mg > 2000
      if @hours_elapsed && @hours_elapsed < 0
        @errors << "Hours elapsed must be zero or positive"
      end
      if @consumed_at && !@consumed_at.match?(/\A\d{1,2}:\d{2}\z/)
        @errors << "Consumed-at time must be in HH:MM format"
      end
      if @sleep_time && !@sleep_time.match?(/\A\d{1,2}:\d{2}\z/)
        @errors << "Sleep time must be in HH:MM format"
      end
    end
  end
end
