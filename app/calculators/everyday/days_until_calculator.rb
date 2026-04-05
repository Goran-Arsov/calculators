# frozen_string_literal: true

module Everyday
  class DaysUntilCalculator
    attr_reader :errors

    def initialize(target_date:, from_date: nil)
      @target_date_str = target_date.to_s
      @from_date_str = (from_date || Date.today).to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      target_d = Date.parse(@target_date_str)
      from_d = Date.parse(@from_date_str)

      total_days = (target_d - from_d).to_i
      past = total_days.negative?
      abs_days = total_days.abs

      weeks = abs_days / 7
      remaining_days = abs_days % 7
      total_hours = abs_days * 24
      total_minutes = total_hours * 60

      # Calculate months
      if past
        months = month_difference(target_d, from_d)
      else
        months = month_difference(from_d, target_d)
      end

      # Business days (Mon-Fri)
      business_days = count_business_days(from_d, target_d)

      {
        valid: true,
        total_days: total_days,
        absolute_days: abs_days,
        weeks: weeks,
        remaining_days: remaining_days,
        months: months,
        total_hours: total_hours,
        total_minutes: total_minutes,
        business_days: business_days,
        past: past,
        target_date: target_d.to_s,
        from_date: from_d.to_s
      }
    end

    private

    def month_difference(earlier, later)
      (later.year * 12 + later.month) - (earlier.year * 12 + earlier.month)
    end

    def count_business_days(from_d, target_d)
      if target_d >= from_d
        count = 0
        (from_d...target_d).each do |date|
          count += 1 unless date.saturday? || date.sunday?
        end
        count
      else
        count = 0
        (target_d...from_d).each do |date|
          count += 1 unless date.saturday? || date.sunday?
        end
        -count
      end
    end

    def validate!
      begin
        Date.parse(@target_date_str)
      rescue Date::Error, TypeError
        @errors << "Invalid target date format"
      end

      begin
        Date.parse(@from_date_str)
      rescue Date::Error, TypeError
        @errors << "Invalid from date format"
      end
    end
  end
end
