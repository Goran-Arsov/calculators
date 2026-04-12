# frozen_string_literal: true

require "date"

module Relationships
  class AnniversaryCalculator
    attr_reader :errors

    def initialize(start_date:, reference_date: nil)
      @start_date = parse_date(start_date)
      @reference_date = parse_date(reference_date) || Date.today
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_days = (@reference_date - @start_date).to_i
      years = @reference_date.year - @start_date.year
      months = @reference_date.month - @start_date.month
      days = @reference_date.day - @start_date.day

      if days < 0
        months -= 1
        prev_month = (@reference_date << 1)
        days += Date.civil(prev_month.year, prev_month.month, -1).day
      end
      if months < 0
        years -= 1
        months += 12
      end

      next_anniversary = next_anniversary_date
      days_until_next = (next_anniversary - @reference_date).to_i
      upcoming_year = years + 1

      {
        valid: true,
        total_days: total_days,
        total_weeks: total_days / 7,
        years: years,
        months: months,
        days: days,
        next_anniversary: next_anniversary,
        days_until_next: days_until_next,
        upcoming_anniversary_year: upcoming_year,
        traditional_gift: traditional_gift(upcoming_year)
      }
    end

    private

    def validate!
      @errors << "Start date is required and must be valid" unless @start_date
      return if @errors.any?
      @errors << "Start date cannot be in the future" if @start_date > @reference_date
    end

    def parse_date(value)
      return nil if value.nil?
      return value if value.is_a?(Date)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def next_anniversary_date
      this_year = Date.new(@reference_date.year, @start_date.month, safe_day(@start_date, @reference_date.year))
      return this_year if this_year > @reference_date
      Date.new(@reference_date.year + 1, @start_date.month, safe_day(@start_date, @reference_date.year + 1))
    end

    def safe_day(start, year)
      day = start.day
      last = Date.civil(year, start.month, -1).day
      [ day, last ].min
    end

    TRADITIONAL_GIFTS = {
      1 => "Paper", 2 => "Cotton", 3 => "Leather", 4 => "Fruit/Flowers",
      5 => "Wood", 6 => "Candy/Iron", 7 => "Wool/Copper", 8 => "Bronze",
      9 => "Pottery", 10 => "Tin/Aluminum", 15 => "Crystal", 20 => "China",
      25 => "Silver", 30 => "Pearl", 40 => "Ruby", 50 => "Gold",
      60 => "Diamond", 75 => "Diamond & Gold"
    }.freeze

    def traditional_gift(year)
      TRADITIONAL_GIFTS[year] || TRADITIONAL_GIFTS.keys.reverse.find { |k| k <= year }&.then { |k| TRADITIONAL_GIFTS[k] } || "Your choice"
    end
  end
end
