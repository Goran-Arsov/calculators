# frozen_string_literal: true

module Everyday
  class AgeCalculator
    attr_reader :errors

    def initialize(birth_date:)
      @birth_date_str = birth_date.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      birth = Date.parse(@birth_date_str)
      today = Date.today

      years = today.year - birth.year
      months = today.month - birth.month
      days = today.day - birth.day

      if days.negative?
        months -= 1
        days += (today - (today << 1)).to_i.abs
      end

      if months.negative?
        years -= 1
        months += 12
      end

      total_days = (today - birth).to_i

      next_birthday = Date.new(today.year, birth.month, birth.day)
      next_birthday = Date.new(today.year + 1, birth.month, birth.day) if next_birthday <= today

      {
        valid: true,
        years: years,
        months: months,
        days: days,
        total_days: total_days,
        next_birthday: next_birthday
      }
    end

    private

    def validate!
      begin
        birth = Date.parse(@birth_date_str)
      rescue Date::Error, TypeError
        @errors << "Invalid date format"
        return
      end

      @errors << "Birth date cannot be in the future" if birth > Date.today
    end
  end
end
