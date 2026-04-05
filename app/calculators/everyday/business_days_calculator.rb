# frozen_string_literal: true

module Everyday
  class BusinessDaysCalculator
    attr_reader :errors

    def initialize(start_date:, end_date:, exclude_holidays: [])
      @start_date_str = start_date.to_s
      @end_date_str = end_date.to_s
      @exclude_holidays = Array(exclude_holidays).map { |h| h.is_a?(Date) ? h : Date.parse(h.to_s) }
      @errors = []
    rescue ArgumentError, TypeError
      @errors = [ "Invalid date format in holidays" ]
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      start_d = Date.parse(@start_date_str)
      end_d = Date.parse(@end_date_str)

      calendar_days = (end_d - start_d).to_i
      total_weeks = calendar_days / 7.0

      business_days = 0
      weekend_days = 0
      holidays_excluded = 0

      (start_d...end_d).each do |date|
        if date.saturday? || date.sunday?
          weekend_days += 1
        elsif @exclude_holidays.include?(date)
          holidays_excluded += 1
        else
          business_days += 1
        end
      end

      {
        valid: true,
        calendar_days: calendar_days,
        business_days: business_days,
        weekend_days: weekend_days,
        holidays_excluded: holidays_excluded,
        total_weeks: total_weeks.round(1),
        start_date: start_d.to_s,
        end_date: end_d.to_s
      }
    end

    private

    def validate!
      begin
        Date.parse(@start_date_str)
      rescue Date::Error, TypeError
        @errors << "Invalid start date format"
      end

      begin
        Date.parse(@end_date_str)
      rescue Date::Error, TypeError
        @errors << "Invalid end date format"
      end

      if @errors.empty?
        start_d = Date.parse(@start_date_str)
        end_d = Date.parse(@end_date_str)
        @errors << "End date must be after start date" if end_d < start_d
      end
    end
  end
end
