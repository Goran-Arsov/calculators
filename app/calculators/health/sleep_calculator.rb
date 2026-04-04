module Health
  class SleepCalculator
    attr_reader :errors

    CYCLE_MINUTES = 90
    FALL_ASLEEP_MINUTES = 15
    CYCLE_COUNTS = [6, 5, 4, 3].freeze
    MODES = %w[wake_time bed_time].freeze

    def initialize(mode:, time:)
      @mode = mode.to_s
      @time = time.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed_time = parse_time(@time)
      suggestions = calculate_suggestions(parsed_time)

      {
        valid: true,
        suggestions: suggestions
      }
    end

    private

    def parse_time(time_str)
      parts = time_str.split(":")
      hours = parts[0].to_i
      minutes = parts[1].to_i
      { hours: hours, minutes: minutes }
    end

    def time_in_minutes(time_hash)
      time_hash[:hours] * 60 + time_hash[:minutes]
    end

    def minutes_to_time(total_minutes)
      total_minutes = total_minutes % (24 * 60)
      total_minutes += 24 * 60 if total_minutes < 0
      hours = total_minutes / 60
      minutes = total_minutes % 60
      format("%02d:%02d", hours, minutes)
    end

    def calculate_suggestions(parsed_time)
      base_minutes = time_in_minutes(parsed_time)

      CYCLE_COUNTS.map do |cycles|
        sleep_duration = cycles * CYCLE_MINUTES

        if @mode == "wake_time"
          # Subtract sleep duration and fall-asleep time from wake time
          suggested_minutes = base_minutes - sleep_duration - FALL_ASLEEP_MINUTES
          {
            time: minutes_to_time(suggested_minutes),
            cycles: cycles,
            sleep_hours: (sleep_duration / 60.0).round(1)
          }
        else
          # Add fall-asleep time and sleep duration to bed time
          suggested_minutes = base_minutes + FALL_ASLEEP_MINUTES + sleep_duration
          {
            time: minutes_to_time(suggested_minutes),
            cycles: cycles,
            sleep_hours: (sleep_duration / 60.0).round(1)
          }
        end
      end
    end

    def validate!
      unless MODES.include?(@mode)
        @errors << "Mode must be wake_time or bed_time"
        return
      end

      unless @time.match?(/\A\d{1,2}:\d{2}\z/)
        @errors << "Time must be in HH:MM format"
        return
      end

      parts = @time.split(":")
      hours = parts[0].to_i
      minutes = parts[1].to_i

      @errors << "Hours must be between 0 and 23" unless hours.between?(0, 23)
      @errors << "Minutes must be between 0 and 59" unless minutes.between?(0, 59)
    end
  end
end
