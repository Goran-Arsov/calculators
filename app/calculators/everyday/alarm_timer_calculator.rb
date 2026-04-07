# frozen_string_literal: true

module Everyday
  class AlarmTimerCalculator
    attr_reader :errors

    def initialize(hours:, minutes:, seconds:)
      @hours = hours.to_i
      @minutes = minutes.to_i
      @seconds = seconds.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_seconds = @hours * 3600 + @minutes * 60 + @seconds
      formatted_time = format("%02d:%02d:%02d", @hours, @minutes, @seconds)

      {
        valid: true,
        total_seconds: total_seconds,
        formatted_time: formatted_time,
        hours: @hours,
        minutes: @minutes,
        seconds: @seconds
      }
    end

    private

    def validate!
      if @hours.zero? && @minutes.zero? && @seconds.zero?
        @errors << "At least one value must be greater than zero"
      end

      if @hours.negative? || @hours > 23
        @errors << "Hours must be between 0 and 23"
      end

      if @minutes.negative? || @minutes > 59
        @errors << "Minutes must be between 0 and 59"
      end

      if @seconds.negative? || @seconds > 59
        @errors << "Seconds must be between 0 and 59"
      end
    end
  end
end
