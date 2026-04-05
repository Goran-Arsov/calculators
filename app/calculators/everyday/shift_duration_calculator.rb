# frozen_string_literal: true

module Everyday
  class ShiftDurationCalculator
    MINUTES_IN_DAY = 1440

    attr_reader :errors

    def initialize(start_time:, end_time:, break_minutes: 0)
      @start_time_str = start_time.to_s
      @end_time_str = end_time.to_s
      @break_minutes = break_minutes.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      start_minutes = parse_time_to_minutes(@start_time_str)
      end_minutes = parse_time_to_minutes(@end_time_str)

      # Handle overnight shifts (e.g., 22:00 to 06:00)
      total_minutes = if end_minutes > start_minutes
                        end_minutes - start_minutes
      else
                        (MINUTES_IN_DAY - start_minutes) + end_minutes
      end

      overnight = end_minutes <= start_minutes
      paid_minutes = [ total_minutes - @break_minutes, 0 ].max
      total_hours = total_minutes / 60.0
      paid_hours = paid_minutes / 60.0

      {
        valid: true,
        start_time: @start_time_str,
        end_time: @end_time_str,
        overnight: overnight,
        total_minutes: total_minutes.round(0),
        total_hours: total_hours.round(2),
        break_minutes: @break_minutes.round(0),
        paid_minutes: paid_minutes.round(0),
        paid_hours: paid_hours.round(2)
      }
    end

    private

    def parse_time_to_minutes(time_str)
      parts = time_str.strip.split(":")
      hours = parts[0].to_i
      minutes = parts[1].to_i
      hours * 60 + minutes
    end

    def valid_time_format?(time_str)
      return false if time_str.nil? || time_str.strip.empty?

      parts = time_str.strip.split(":")
      return false unless parts.length == 2

      hours = parts[0].to_i
      minutes = parts[1].to_i
      hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59 && parts[0].match?(/\A\d{1,2}\z/) && parts[1].match?(/\A\d{1,2}\z/)
    end

    def validate!
      @errors << "Invalid start time format (use HH:MM)" unless valid_time_format?(@start_time_str)
      @errors << "Invalid end time format (use HH:MM)" unless valid_time_format?(@end_time_str)
      @errors << "Break minutes must be zero or positive" if @break_minutes.negative?

      if @errors.empty?
        start_minutes = parse_time_to_minutes(@start_time_str)
        end_minutes = parse_time_to_minutes(@end_time_str)
        total_minutes = if end_minutes > start_minutes
                          end_minutes - start_minutes
        else
                          (MINUTES_IN_DAY - start_minutes) + end_minutes
        end
        @errors << "Break time cannot exceed shift duration" if @break_minutes > total_minutes
      end
    end
  end
end
