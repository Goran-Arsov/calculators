# frozen_string_literal: true

module Health
  class IntermittentFastingCalculator
    attr_reader :errors

    FASTING_METHODS = {
      "16_8" => { fasting_hours: 16, eating_hours: 8, name: "16:8 (Leangains)" },
      "18_6" => { fasting_hours: 18, eating_hours: 6, name: "18:6" },
      "20_4" => { fasting_hours: 20, eating_hours: 4, name: "20:4 (Warrior Diet)" },
      "14_10" => { fasting_hours: 14, eating_hours: 10, name: "14:10" },
      "omad" => { fasting_hours: 23, eating_hours: 1, name: "OMAD (One Meal a Day)" }
    }.freeze

    def initialize(method:, start_time:)
      @method = method.to_s
      @start_time = parse_time(start_time)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fasting_info = FASTING_METHODS[@method]

      fasting_start = @start_time
      fasting_end = add_hours(fasting_start, fasting_info[:fasting_hours])
      eating_start = fasting_end
      eating_end = add_hours(eating_start, fasting_info[:eating_hours])

      # Build daily schedule
      schedule = build_schedule(fasting_start, fasting_end, eating_start, eating_end, fasting_info)

      {
        valid: true,
        method_name: fasting_info[:name],
        fasting_hours: fasting_info[:fasting_hours],
        eating_hours: fasting_info[:eating_hours],
        fasting_start: format_time(fasting_start),
        fasting_end: format_time(fasting_end),
        eating_start: format_time(eating_start),
        eating_end: format_time(eating_end),
        schedule: schedule
      }
    end

    private

    def parse_time(value)
      return nil if value.nil? || value.to_s.strip.empty?
      parts = value.to_s.strip.split(":")
      return nil unless parts.length == 2
      hour = parts[0].to_i
      minute = parts[1].to_i
      return nil unless hour.between?(0, 23) && minute.between?(0, 59)
      { hour: hour, minute: minute }
    rescue
      nil
    end

    def add_hours(time, hours)
      total_minutes = time[:hour] * 60 + time[:minute] + hours * 60
      new_hour = (total_minutes / 60) % 24
      new_minute = total_minutes % 60
      { hour: new_hour, minute: new_minute }
    end

    def format_time(time)
      period = time[:hour] >= 12 ? "PM" : "AM"
      display_hour = time[:hour] % 12
      display_hour = 12 if display_hour == 0
      format("%d:%02d %s", display_hour, time[:minute], period)
    end

    def build_schedule(fasting_start, fasting_end, eating_start, eating_end, fasting_info)
      schedule = []

      schedule << {
        time: format_time(fasting_start),
        event: "Begin fasting",
        description: "Start your #{fasting_info[:fasting_hours]}-hour fast. Water, black coffee, and plain tea are allowed."
      }

      # Mid-fast check-in
      mid_fast = add_hours(fasting_start, fasting_info[:fasting_hours] / 2)
      schedule << {
        time: format_time(mid_fast),
        event: "Mid-fast",
        description: "Halfway through your fast. Stay hydrated."
      }

      schedule << {
        time: format_time(eating_start),
        event: "Eating window opens",
        description: "Break your fast. Start with a balanced meal rich in protein and healthy fats."
      }

      if fasting_info[:eating_hours] > 1
        mid_eating = add_hours(eating_start, fasting_info[:eating_hours] / 2)
        schedule << {
          time: format_time(mid_eating),
          event: "Mid eating window",
          description: "Have your second meal if desired. Focus on nutrient-dense whole foods."
        }
      end

      # Last meal reminder (30 min before eating window closes)
      last_meal = add_hours(eating_end, 0)
      last_meal_reminder = add_hours(eating_start, fasting_info[:eating_hours] - 1)
      if fasting_info[:eating_hours] > 2
        schedule << {
          time: format_time(last_meal_reminder),
          event: "Prepare for last meal",
          description: "Finish eating soon. Your eating window closes in about 1 hour."
        }
      end

      schedule << {
        time: format_time(eating_end),
        event: "Eating window closes",
        description: "Begin your next #{fasting_info[:fasting_hours]}-hour fast."
      }

      schedule
    end

    def validate!
      @errors << "Fasting method is required" unless FASTING_METHODS.key?(@method)
      @errors << "Start time is required and must be in HH:MM format" if @start_time.nil?
    end
  end
end
