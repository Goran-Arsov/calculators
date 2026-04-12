# frozen_string_literal: true

require "date"

module Relationships
  class AgeGapCalculator
    attr_reader :errors

    def initialize(birth1:, birth2:)
      @birth1 = parse_date(birth1)
      @birth2 = parse_date(birth2)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      older, younger = [ @birth1, @birth2 ].minmax
      total_days = (younger - older).to_i

      years = younger.year - older.year
      months = younger.month - older.month
      days = younger.day - older.day

      if days < 0
        months -= 1
        prev_month = (younger << 1)
        days += Date.civil(prev_month.year, prev_month.month, -1).day
      end
      if months < 0
        years -= 1
        months += 12
      end

      older_age = age_at(older, Date.today)
      younger_age = age_at(younger, Date.today)

      min_acceptable = (older_age / 2.0) + 7
      max_acceptable = (older_age - 7) * 2
      rule_passes = younger_age >= min_acceptable

      {
        valid: true,
        years: years,
        months: months,
        days: days,
        total_days: total_days,
        older_age: older_age,
        younger_age: younger_age,
        min_acceptable_partner_age: min_acceptable.floor,
        max_acceptable_partner_age: max_acceptable.floor,
        rule_passes: rule_passes
      }
    end

    private

    def validate!
      @errors << "Both birth dates are required" unless @birth1 && @birth2
      return if @errors.any?
      @errors << "Birth dates cannot be in the future" if @birth1 > Date.today || @birth2 > Date.today
    end

    def parse_date(value)
      return value if value.is_a?(Date)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def age_at(birth, today)
      age = today.year - birth.year
      age -= 1 if today < birth + (age * 365.25).to_i
      age
    end
  end
end
