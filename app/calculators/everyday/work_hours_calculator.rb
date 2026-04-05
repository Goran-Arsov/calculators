# frozen_string_literal: true

module Everyday
  class WorkHoursCalculator
    attr_reader :errors

    def initialize(start_date:, end_date:, hours_per_day: 8, days_per_week: 5)
      @start_date_str = start_date.to_s
      @end_date_str = end_date.to_s
      @hours_per_day = hours_per_day.to_f
      @days_per_week = days_per_week.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      start_d = Date.parse(@start_date_str)
      end_d = Date.parse(@end_date_str)

      calendar_days = (end_d - start_d).to_i
      total_weeks = calendar_days / 7.0
      work_days = count_work_days(start_d, end_d)
      total_hours = work_days * @hours_per_day

      {
        valid: true,
        calendar_days: calendar_days,
        total_weeks: total_weeks.round(1),
        work_days: work_days,
        total_hours: total_hours.round(1),
        hours_per_day: @hours_per_day,
        days_per_week: @days_per_week
      }
    end

    private

    def count_work_days(start_d, end_d)
      # Count days that fall on the configured working days
      # For days_per_week <= 5, count Mon-Fri (or fewer)
      # For days_per_week 6, count Mon-Sat
      # For days_per_week 7, count all days
      count = 0
      working_wdays = working_weekdays

      (start_d...end_d).each do |date|
        count += 1 if working_wdays.include?(date.wday)
      end

      count
    end

    def working_weekdays
      # wday: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
      case @days_per_week
      when 7 then [ 0, 1, 2, 3, 4, 5, 6 ]
      when 6 then [ 1, 2, 3, 4, 5, 6 ]
      when 5 then [ 1, 2, 3, 4, 5 ]
      when 4 then [ 1, 2, 3, 4 ]
      when 3 then [ 1, 2, 3 ]
      when 2 then [ 1, 2 ]
      when 1 then [ 1 ]
      else []
      end
    end

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

      @errors << "Hours per day must be between 0 and 24" unless @hours_per_day.positive? && @hours_per_day <= 24
      @errors << "Days per week must be between 1 and 7" unless @days_per_week >= 1 && @days_per_week <= 7
    end
  end
end
