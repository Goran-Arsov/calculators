# frozen_string_literal: true

require "date"

module Relationships
  class DatingDurationCalculator
    attr_reader :errors

    def initialize(first_date:, reference_date: nil)
      @first_date = parse_date(first_date)
      @reference_date = parse_date(reference_date) || Date.today
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_days = (@reference_date - @first_date).to_i
      total_hours = total_days * 24
      total_minutes = total_hours * 60
      total_weeks = total_days / 7
      total_months = (total_days / 30.4375).floor
      total_years = total_days / 365.25

      {
        valid: true,
        total_days: total_days,
        total_hours: total_hours,
        total_minutes: total_minutes,
        total_weeks: total_weeks,
        total_months: total_months,
        total_years: total_years.round(2),
        friendly: friendly_summary(total_days)
      }
    end

    private

    def validate!
      @errors << "First date is required and must be valid" unless @first_date
      return if @errors.any?
      @errors << "First date cannot be in the future" if @first_date > @reference_date
    end

    def parse_date(value)
      return nil if value.nil?
      return value if value.is_a?(Date)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def friendly_summary(days)
      y = days / 365
      remaining = days % 365
      m = remaining / 30
      d = remaining % 30
      parts = []
      parts << "#{y} year#{'s' unless y == 1}" if y.positive?
      parts << "#{m} month#{'s' unless m == 1}" if m.positive?
      parts << "#{d} day#{'s' unless d == 1}" if d.positive? || parts.empty?
      parts.join(", ")
    end
  end
end
