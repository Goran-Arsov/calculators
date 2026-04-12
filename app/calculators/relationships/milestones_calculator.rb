# frozen_string_literal: true

require "date"

module Relationships
  class MilestonesCalculator
    attr_reader :errors

    MILESTONES = [
      { key: :first_kiss, label: "First kiss", avg_days: 14 },
      { key: :said_i_love_you, label: "Said 'I love you'", avg_days: 120 },
      { key: :met_parents, label: "Met the parents", avg_days: 150 },
      { key: :first_vacation, label: "First vacation together", avg_days: 240 },
      { key: :moved_in, label: "Moved in together", avg_days: 525 },
      { key: :got_a_pet, label: "Got a pet together", avg_days: 700 },
      { key: :engagement, label: "Engagement", avg_days: 900 },
      { key: :marriage, label: "Marriage", avg_days: 1365 },
      { key: :first_child, label: "First child", avg_days: 1820 }
    ].freeze

    def initialize(start_date:, reference_date: nil)
      @start_date = parse_date(start_date)
      @reference_date = parse_date(reference_date) || Date.today
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_days = (@reference_date - @start_date).to_i

      events = MILESTONES.map do |ms|
        passed = total_days >= ms[:avg_days]
        days_away = ms[:avg_days] - total_days
        {
          key: ms[:key],
          label: ms[:label],
          avg_days: ms[:avg_days],
          passed: passed,
          days_away: passed ? 0 : days_away,
          date_estimate: @start_date + ms[:avg_days]
        }
      end

      {
        valid: true,
        total_days: total_days,
        milestones: events,
        next_milestone: events.find { |e| !e[:passed] }
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
  end
end
