# frozen_string_literal: true

module Everyday
  class UnixTimestampCalculator
    attr_reader :errors

    def initialize(input:, mode: :to_datetime)
      @input = input.to_s.strip
      @mode = mode.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when :to_datetime
        convert_to_datetime
      when :to_timestamp
        convert_to_timestamp
      else
        @errors << "Invalid mode. Use :to_datetime or :to_timestamp"
        { valid: false, errors: @errors }
      end
    end

    private

    def validate!
      @errors << "Input cannot be empty" if @input.empty?

      return if @errors.any?

      case @mode
      when :to_datetime
        unless @input.match?(/\A-?\d+(\.\d+)?\z/)
          @errors << "Timestamp must be a valid integer or decimal number"
        end
      when :to_timestamp
        begin
          Time.parse(@input)
        rescue ArgumentError, TypeError
          @errors << "Invalid datetime format. Use ISO 8601 or a standard datetime string"
        end
      end
    end

    def convert_to_datetime
      timestamp = @input.to_f
      time = Time.at(timestamp).utc

      {
        valid: true,
        unix_timestamp: timestamp.to_i,
        millisecond_timestamp: (timestamp * 1000).to_i,
        iso8601: time.iso8601,
        rfc2822: time.rfc2822,
        utc: time.strftime("%Y-%m-%d %H:%M:%S UTC"),
        local_format: time.strftime("%B %d, %Y at %I:%M:%S %p UTC"),
        date_only: time.strftime("%Y-%m-%d"),
        time_only: time.strftime("%H:%M:%S"),
        day_of_week: time.strftime("%A"),
        is_past: time < Time.now.utc,
        relative_time: relative_time_description(time)
      }
    end

    def convert_to_timestamp
      time = Time.parse(@input).utc

      {
        valid: true,
        unix_timestamp: time.to_i,
        millisecond_timestamp: (time.to_f * 1000).to_i,
        iso8601: time.iso8601,
        rfc2822: time.rfc2822,
        utc: time.strftime("%Y-%m-%d %H:%M:%S UTC"),
        local_format: time.strftime("%B %d, %Y at %I:%M:%S %p UTC"),
        date_only: time.strftime("%Y-%m-%d"),
        time_only: time.strftime("%H:%M:%S"),
        day_of_week: time.strftime("%A"),
        is_past: time < Time.now.utc,
        relative_time: relative_time_description(time)
      }
    end

    def relative_time_description(time)
      now = Time.now.utc
      diff = (now - time).abs
      direction = time < now ? "ago" : "from now"

      description = if diff < 60
        "#{diff.to_i} seconds"
      elsif diff < 3600
        minutes = (diff / 60).to_i
        "#{minutes} #{minutes == 1 ? 'minute' : 'minutes'}"
      elsif diff < 86_400
        hours = (diff / 3600).to_i
        "#{hours} #{hours == 1 ? 'hour' : 'hours'}"
      elsif diff < 2_592_000
        days = (diff / 86_400).to_i
        "#{days} #{days == 1 ? 'day' : 'days'}"
      elsif diff < 31_536_000
        months = (diff / 2_592_000).to_i
        "#{months} #{months == 1 ? 'month' : 'months'}"
      else
        years = (diff / 31_536_000).to_i
        "#{years} #{years == 1 ? 'year' : 'years'}"
      end

      "#{description} #{direction}"
    end
  end
end
