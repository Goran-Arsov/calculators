# frozen_string_literal: true

module Everyday
  class TimeZoneConverterCalculator
    attr_reader :errors

    TIMEZONES = {
      "UTC"    => 0,
      "EST"    => -5,
      "EDT"    => -4,
      "CST"    => -6,
      "CDT"    => -5,
      "MST"    => -7,
      "MDT"    => -6,
      "PST"    => -8,
      "PDT"    => -7,
      "AKST"   => -9,
      "AKDT"   => -8,
      "HST"    => -10,
      "GMT"    => 0,
      "BST"    => 1,
      "CET"    => 1,
      "CEST"   => 2,
      "EET"    => 2,
      "EEST"   => 3,
      "MSK"    => 3,
      "IST"    => 5.5,
      "ICT"    => 7,
      "CST_CN" => 8,
      "JST"    => 9,
      "KST"    => 9,
      "AEST"   => 10,
      "AEDT"   => 11,
      "NZST"   => 12,
      "NZDT"   => 13
    }.freeze

    def initialize(hour:, minute:, source_zone:, target_zone:)
      @hour = hour.to_i
      @minute = minute.to_i
      @source_zone = source_zone.to_s.upcase.strip
      @target_zone = target_zone.to_s.upcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      source_offset = TIMEZONES[@source_zone]
      target_offset = TIMEZONES[@target_zone]
      offset_diff = target_offset - source_offset

      total_minutes = @hour * 60 + @minute + (offset_diff * 60).to_i
      day_shift = 0

      if total_minutes < 0
        day_shift = -1
        total_minutes += 1440
      elsif total_minutes >= 1440
        day_shift = 1
        total_minutes -= 1440
      end

      converted_hour = total_minutes / 60
      converted_minute = total_minutes % 60

      {
        valid: true,
        converted_hour: converted_hour,
        converted_minute: converted_minute,
        offset_diff: offset_diff,
        day_shift: day_shift,
        source_zone: @source_zone,
        target_zone: @target_zone,
        formatted_time: format("%02d:%02d", converted_hour, converted_minute)
      }
    end

    private

    def validate!
      @errors << "Hour must be between 0 and 23" unless @hour.between?(0, 23)
      @errors << "Minute must be between 0 and 59" unless @minute.between?(0, 59)
      @errors << "Unknown source timezone: #{@source_zone}" unless TIMEZONES.key?(@source_zone)
      @errors << "Unknown target timezone: #{@target_zone}" unless TIMEZONES.key?(@target_zone)
    end
  end
end
