# frozen_string_literal: true

require "date"

module Relationships
  class DaysUntilWeddingCalculator
    attr_reader :errors

    def initialize(wedding_date:, reference_date: nil)
      @wedding_date = parse_date(wedding_date)
      @reference_date = parse_date(reference_date) || Date.today
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      days = (@wedding_date - @reference_date).to_i
      hours = days * 24
      minutes = hours * 60
      weeks = days / 7
      months = (days / 30.4375).floor
      is_past = days.negative?

      {
        valid: true,
        days: days,
        hours: hours,
        minutes: minutes,
        weeks: weeks,
        months: months,
        is_past: is_past,
        milestone: next_planning_milestone(days)
      }
    end

    private

    def validate!
      @errors << "Wedding date is required and must be valid" unless @wedding_date
    end

    def parse_date(value)
      return nil if value.nil?
      return value if value.is_a?(Date)
      Date.parse(value.to_s)
    rescue ArgumentError, TypeError
      nil
    end

    def next_planning_milestone(days)
      return "Already married — congrats!" if days < 0
      case days
      when 0..14 then "Final week: confirm vendors, seating, speeches"
      when 15..30 then "One month out: rehearsal dinner, final dress fitting"
      when 31..60 then "Two months out: finalize guest count, send final payments"
      when 61..90 then "Three months out: mail invitations, book honeymoon flights"
      when 91..180 then "Six months out: book florist, officiant, and finalize menu"
      when 181..365 then "One year out: book venue, photographer, and DJ"
      else "More than a year out: set the date and start a budget"
      end
    end
  end
end
