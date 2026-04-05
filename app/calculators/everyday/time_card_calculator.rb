# frozen_string_literal: true

module Everyday
  class TimeCardCalculator
    MINUTES_IN_DAY = 1440

    attr_reader :errors

    def initialize(clock_in:, clock_out:, break_minutes: 0, hourly_rate: 0)
      @clock_in_str = clock_in.to_s
      @clock_out_str = clock_out.to_s
      @break_minutes = break_minutes.to_f
      @hourly_rate = hourly_rate.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      in_minutes = parse_time_to_minutes(@clock_in_str)
      out_minutes = parse_time_to_minutes(@clock_out_str)

      # Handle overnight shifts
      total_minutes = if out_minutes > in_minutes
                        out_minutes - in_minutes
      else
                        (MINUTES_IN_DAY - in_minutes) + out_minutes
      end

      worked_minutes = [ total_minutes - @break_minutes, 0 ].max
      hours_worked = worked_minutes / 60.0
      gross_pay = hours_worked * @hourly_rate
      weekly_hours = hours_worked * 5
      weekly_pay = gross_pay * 5
      overnight = out_minutes <= in_minutes

      {
        valid: true,
        clock_in: @clock_in_str,
        clock_out: @clock_out_str,
        overnight: overnight,
        total_minutes: total_minutes.round(0),
        break_minutes: @break_minutes.round(0),
        worked_minutes: worked_minutes.round(0),
        hours_worked: hours_worked.round(2),
        hourly_rate: @hourly_rate.round(2),
        gross_pay: gross_pay.round(2),
        weekly_hours: weekly_hours.round(1),
        weekly_pay: weekly_pay.round(2)
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
      @errors << "Invalid clock-in time format (use HH:MM)" unless valid_time_format?(@clock_in_str)
      @errors << "Invalid clock-out time format (use HH:MM)" unless valid_time_format?(@clock_out_str)
      @errors << "Break minutes must be zero or positive" if @break_minutes.negative?
      @errors << "Hourly rate must be zero or positive" if @hourly_rate.negative?

      if @errors.empty? && @clock_in_str == @clock_out_str
        @errors << "Clock-in and clock-out times cannot be the same"
      end

      if @errors.empty?
        in_minutes = parse_time_to_minutes(@clock_in_str)
        out_minutes = parse_time_to_minutes(@clock_out_str)
        total_minutes = if out_minutes > in_minutes
                          out_minutes - in_minutes
        else
                          (MINUTES_IN_DAY - in_minutes) + out_minutes
        end
        @errors << "Break time cannot exceed total shift time" if @break_minutes > total_minutes
      end
    end
  end
end
