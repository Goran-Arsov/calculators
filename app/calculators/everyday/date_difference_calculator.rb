# frozen_string_literal: true

module Everyday
  class DateDifferenceCalculator
    attr_reader :errors

    def initialize(start_date:, end_date:)
      @start_date_str = start_date.to_s
      @end_date_str = end_date.to_s
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      start_d = Date.parse(@start_date_str)
      end_d = Date.parse(@end_date_str)

      total_days = (end_d - start_d).to_i.abs
      weeks = total_days / 7

      # Calculate years and months
      earlier = [ start_d, end_d ].min
      later = [ start_d, end_d ].max

      years = later.year - earlier.year
      months = later.month - earlier.month
      day_diff = later.day - earlier.day

      if day_diff.negative?
        months -= 1
      end

      if months.negative?
        years -= 1
        months += 12
      end

      total_months = (years * 12) + months

      {
        total_days: total_days,
        weeks: weeks,
        months: total_months,
        years: years
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
    end
  end
end
