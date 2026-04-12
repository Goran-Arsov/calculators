# frozen_string_literal: true

module Everyday
  class TimezoneMeetingPlannerCalculator
    attr_reader :errors

    # Common timezone offsets from UTC (hours)
    TIMEZONE_OFFSETS = {
      "UTC" => 0,
      "GMT" => 0,
      "EST" => -5, "EDT" => -4,
      "CST" => -6, "CDT" => -5,
      "MST" => -7, "MDT" => -6,
      "PST" => -8, "PDT" => -7,
      "AKST" => -9, "AKDT" => -8,
      "HST" => -10,
      "AST" => -4,
      "NST" => -3.5,
      "BRT" => -3,
      "ART" => -3,
      "CET" => 1, "CEST" => 2,
      "EET" => 2, "EEST" => 3,
      "MSK" => 3,
      "GST" => 4,
      "IST" => 5.5,
      "NPT" => 5.75,
      "BST" => 6,
      "ICT" => 7,
      "CST_ASIA" => 8,
      "HKT" => 8,
      "SGT" => 8,
      "JST" => 9,
      "KST" => 9,
      "ACST" => 9.5,
      "AEST" => 10, "AEDT" => 11,
      "NZST" => 12, "NZDT" => 13
    }.freeze

    DEFAULT_BUSINESS_START = 9
    DEFAULT_BUSINESS_END = 17

    def initialize(timezones:, business_start: DEFAULT_BUSINESS_START, business_end: DEFAULT_BUSINESS_END)
      @timezones = normalize_timezones(timezones)
      @business_start = business_start.to_i
      @business_end = business_end.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      overlapping_hours = find_overlap
      schedule = build_schedule

      {
        valid: true,
        timezones: @timezones,
        business_start: @business_start,
        business_end: @business_end,
        overlapping_hours: overlapping_hours,
        overlap_count: overlapping_hours.size,
        schedule: schedule,
        has_overlap: overlapping_hours.any?
      }
    end

    private

    def normalize_timezones(tzs)
      case tzs
      when Array
        tzs.map(&:to_s).map(&:strip).reject(&:empty?).map(&:upcase)
      when String
        tzs.split(/[,\n]/).map(&:strip).reject(&:empty?).map(&:upcase)
      else
        []
      end
    end

    def validate!
      @errors << "At least two timezones are required" if @timezones.size < 2
      @errors << "Business start hour must be between 0 and 23" unless (0..23).cover?(@business_start)
      @errors << "Business end hour must be between 1 and 24" unless (1..24).cover?(@business_end)
      @errors << "Business end must be after business start" if @business_end <= @business_start

      unknown = @timezones.reject { |tz| TIMEZONE_OFFSETS.key?(tz) }
      @errors << "Unknown timezones: #{unknown.join(', ')}" if unknown.any?
    end

    def find_overlap
      # For each UTC hour (0-23), check if it falls within business hours for ALL timezones
      overlapping = []

      (0..23).each do |utc_hour|
        all_within = @timezones.all? do |tz|
          offset = TIMEZONE_OFFSETS[tz]
          local_hour = (utc_hour + offset) % 24
          local_hour >= @business_start && local_hour < @business_end
        end

        if all_within
          overlapping << {
            utc_hour: utc_hour,
            local_times: @timezones.each_with_object({}) do |tz, hash|
              offset = TIMEZONE_OFFSETS[tz]
              local_hour = (utc_hour + offset) % 24
              hash[tz] = format_hour(local_hour)
            end
          }
        end
      end

      overlapping
    end

    def build_schedule
      # Build a 24-hour schedule showing local times for each timezone
      (0..23).map do |utc_hour|
        {
          utc_hour: utc_hour,
          utc_display: format_hour(utc_hour),
          timezones: @timezones.each_with_object({}) do |tz, hash|
            offset = TIMEZONE_OFFSETS[tz]
            local_hour = (utc_hour + offset) % 24
            hash[tz] = {
              hour: local_hour,
              display: format_hour(local_hour),
              is_business: local_hour >= @business_start && local_hour < @business_end
            }
          end
        }
      end
    end

    def format_hour(hour)
      h = hour.to_i
      suffix = h >= 12 ? "PM" : "AM"
      display_hour = h % 12
      display_hour = 12 if display_hour == 0
      "#{display_hour}:00 #{suffix}"
    end
  end
end
