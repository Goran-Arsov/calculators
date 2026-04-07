# frozen_string_literal: true

module Everyday
  class AlarmClockCalculator
    attr_reader :errors

    def initialize(hour:, minute:, day: nil)
      @hour = hour.to_i
      @minute = minute.to_i
      @day = day.to_s.strip.presence
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      formatted_time = format("%02d:%02d", @hour, @minute)

      result = {
        valid: true,
        formatted_time: formatted_time,
        hour: @hour,
        minute: @minute
      }

      result[:formatted_day] = @day if @day

      result
    end

    private

    def validate!
      if @hour.negative? || @hour > 23
        @errors << "Hour must be between 0 and 23"
      end

      if @minute.negative? || @minute > 59
        @errors << "Minute must be between 0 and 59"
      end
    end
  end
end
