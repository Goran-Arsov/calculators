# frozen_string_literal: true

module Everyday
  class CronParserCalculator
    attr_reader :errors

    MONTH_NAMES = %w[_ January February March April May June July August September October November December].freeze
    DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

    FIELD_NAMES = %w[minute hour day_of_month month day_of_week].freeze
    FIELD_RANGES = {
      "minute" => 0..59,
      "hour" => 0..23,
      "day_of_month" => 1..31,
      "month" => 1..12,
      "day_of_week" => 0..6
    }.freeze

    def initialize(expression:, from_time: nil)
      @expression = expression.to_s.strip
      @from_time = from_time || Time.now
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fields = @expression.split(/\s+/)
      unless fields.length == 5
        @errors << "Expected 5 fields (minute hour day-of-month month day-of-week), got #{fields.length}"
        return { valid: false, errors: @errors }
      end

      parsed = parse_fields(fields)
      return { valid: false, errors: @errors } if @errors.any?

      description = build_description(parsed)
      field_descriptions = build_field_descriptions(fields, parsed)
      next_runs = calculate_next_runs(parsed, 5)

      {
        valid: true,
        expression: @expression,
        description: description,
        next_runs: next_runs.map { |t| t.strftime("%Y-%m-%d %H:%M:%S %Z") },
        fields: field_descriptions,
        minute: fields[0],
        hour: fields[1],
        day_of_month: fields[2],
        month: fields[3],
        day_of_week: fields[4]
      }
    end

    private

    def validate!
      @errors << "Expression cannot be empty" if @expression.empty?
    end

    def parse_fields(fields)
      result = {}
      FIELD_NAMES.each_with_index do |name, i|
        result[name] = parse_field(fields[i], FIELD_RANGES[name], name)
      end
      result
    end

    def parse_field(field, range, name)
      values = []

      field.split(",").each do |part|
        case part
        when "*"
          values.concat(range.to_a)
        when /\A\*\/(\d+)\z/
          step = ::Regexp.last_match(1).to_i
          if step <= 0
            @errors << "Invalid step value '#{step}' in #{name}"
            return []
          end
          range.step(step) { |v| values << v }
        when /\A(\d+)-(\d+)\z/
          start_val = ::Regexp.last_match(1).to_i
          end_val = ::Regexp.last_match(2).to_i
          unless range.include?(start_val) && range.include?(end_val)
            @errors << "Range #{start_val}-#{end_val} out of bounds for #{name} (#{range.first}-#{range.last})"
            return []
          end
          values.concat((start_val..end_val).to_a)
        when /\A(\d+)-(\d+)\/(\d+)\z/
          start_val = ::Regexp.last_match(1).to_i
          end_val = ::Regexp.last_match(2).to_i
          step = ::Regexp.last_match(3).to_i
          unless range.include?(start_val) && range.include?(end_val)
            @errors << "Range #{start_val}-#{end_val} out of bounds for #{name} (#{range.first}-#{range.last})"
            return []
          end
          (start_val..end_val).step(step) { |v| values << v }
        when /\A\d+\z/
          val = part.to_i
          unless range.include?(val)
            @errors << "Value #{val} out of bounds for #{name} (#{range.first}-#{range.last})"
            return []
          end
          values << val
        else
          @errors << "Invalid syntax '#{part}' in #{name} field"
          return []
        end
      end

      values.uniq.sort
    end

    def build_description(parsed)
      minute = parsed["minute"]
      hour = parsed["hour"]
      dom = parsed["day_of_month"]
      month = parsed["month"]
      dow = parsed["day_of_week"]

      all_minutes = minute == (0..59).to_a
      all_hours = hour == (0..23).to_a
      all_dom = dom == (1..31).to_a
      all_months = month == (1..12).to_a
      all_dow = dow == (0..6).to_a

      # Every minute
      if all_minutes && all_hours && all_dom && all_months && all_dow
        return "Every minute"
      end

      # Every N minutes
      if minute.length > 1 && all_hours && all_dom && all_months && all_dow
        step = detect_step(minute, 0..59)
        return "Every #{step} minutes" if step
      end

      parts = []

      # Time component
      if minute.length == 1 && hour.length == 1
        parts << "At #{format_time(hour[0], minute[0])}"
      elsif minute.length == 1 && all_hours
        parts << "At minute #{minute[0]} of every hour"
      elsif all_minutes && hour.length == 1
        parts << "Every minute during #{format_hour(hour[0])}"
      elsif all_minutes
        parts << "Every minute"
      else
        parts << "At minute #{minute.join(', ')}"
        unless all_hours
          parts << "during hour #{hour.join(', ')}"
        end
      end

      # Day of week
      unless all_dow
        day_names = dow.map { |d| DAY_NAMES[d] }
        parts << "on #{day_names.join(', ')}"
      end

      # Day of month
      unless all_dom
        parts << "on day #{dom.join(', ')} of the month"
      end

      # Month
      unless all_months
        month_names = month.map { |m| MONTH_NAMES[m] }
        parts << "in #{month_names.join(', ')}"
      end

      parts.join(" ")
    end

    def detect_step(values, range)
      return nil if values.length < 2
      diffs = values.each_cons(2).map { |a, b| b - a }
      return nil unless diffs.uniq.length == 1

      step = diffs[0]
      expected = range.step(step).to_a
      return step if values == expected

      nil
    end

    def format_time(hour, minute)
      period = hour >= 12 ? "PM" : "AM"
      display_hour = hour % 12
      display_hour = 12 if display_hour == 0
      format("%d:%02d %s", display_hour, minute, period)
    end

    def format_hour(hour)
      period = hour >= 12 ? "PM" : "AM"
      display_hour = hour % 12
      display_hour = 12 if display_hour == 0
      "#{display_hour} #{period}"
    end

    def build_field_descriptions(fields, parsed)
      descriptions = {}

      FIELD_NAMES.each_with_index do |name, i|
        raw = fields[i]
        values = parsed[name]
        range = FIELD_RANGES[name]

        desc = if raw == "*"
          "Every #{name.tr('_', ' ')}"
        elsif raw.start_with?("*/")
          step = raw.sub("*/", "")
          "Every #{step} #{name.tr('_', ' ')}s"
        elsif raw.include?("-")
          "#{name.tr('_', ' ').capitalize}s #{raw}"
        elsif raw.include?(",")
          "#{name.tr('_', ' ').capitalize}s #{values.join(', ')}"
        else
          label = case name
          when "day_of_week" then DAY_NAMES[values[0]] || values[0].to_s
          when "month" then MONTH_NAMES[values[0]] || values[0].to_s
          else values[0].to_s
          end
          "#{name.tr('_', ' ').capitalize} #{label}"
        end

        descriptions[name] = {
          raw: raw,
          values: values,
          description: desc
        }
      end

      descriptions
    end

    def calculate_next_runs(parsed, count)
      runs = []
      candidate = @from_time + 60 # Start from next minute
      # Round down to the start of the minute
      candidate = Time.new(candidate.year, candidate.month, candidate.day, candidate.hour, candidate.min, 0, candidate.utc_offset)

      max_iterations = 525_960 # ~1 year of minutes
      iterations = 0

      while runs.length < count && iterations < max_iterations
        if matches?(candidate, parsed)
          runs << candidate
        end
        candidate += 60
        iterations += 1
      end

      runs
    end

    def matches?(time, parsed)
      return false unless parsed["minute"].include?(time.min)
      return false unless parsed["hour"].include?(time.hour)
      return false unless parsed["month"].include?(time.month)

      dom_match = parsed["day_of_month"].include?(time.day)
      dow_match = parsed["day_of_week"].include?(time.wday)

      # Standard cron behavior: if both DOM and DOW are restricted, either can match
      dom_restricted = parsed["day_of_month"] != (1..31).to_a
      dow_restricted = parsed["day_of_week"] != (0..6).to_a

      if dom_restricted && dow_restricted
        dom_match || dow_match
      else
        dom_match && dow_match
      end
    end
  end
end
