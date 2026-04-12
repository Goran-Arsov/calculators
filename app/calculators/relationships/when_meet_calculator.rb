# frozen_string_literal: true

module Relationships
  class WhenMeetCalculator
    attr_reader :errors

    CITY_SIZE_FACTOR = {
      "small" => 0.4,
      "medium" => 1.0,
      "large" => 2.0,
      "metro" => 3.0
    }.freeze

    EFFORT_DATES_PER_MONTH = {
      "low" => 1,
      "medium" => 3,
      "high" => 6
    }.freeze

    SELECTIVITY_HIT_RATE = {
      "very_picky" => 0.04,
      "picky" => 0.08,
      "average" => 0.15,
      "open" => 0.30
    }.freeze

    def initialize(city_size:, effort:, selectivity:)
      @city_size = city_size.to_s
      @effort = effort.to_s
      @selectivity = selectivity.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      dates_per_month = EFFORT_DATES_PER_MONTH[@effort]
      hit_rate = SELECTIVITY_HIT_RATE[@selectivity]
      city_factor = CITY_SIZE_FACTOR[@city_size]

      expected_dates_to_match = (1.0 / hit_rate) / city_factor
      months_until_meet = expected_dates_to_match / dates_per_month
      months_until_meet = months_until_meet.clamp(1.0, 60.0)

      {
        valid: true,
        months_until_meet: months_until_meet.round(1),
        weeks_until_meet: (months_until_meet * 4.33).round,
        dates_per_month: dates_per_month,
        dates_needed: expected_dates_to_match.round,
        hit_rate_percent: (hit_rate * 100).round(1)
      }
    end

    private

    def validate!
      @errors << "City size is invalid" unless CITY_SIZE_FACTOR.key?(@city_size)
      @errors << "Effort level is invalid" unless EFFORT_DATES_PER_MONTH.key?(@effort)
      @errors << "Selectivity is invalid" unless SELECTIVITY_HIT_RATE.key?(@selectivity)
    end
  end
end
