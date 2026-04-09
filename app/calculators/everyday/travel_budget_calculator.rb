# frozen_string_literal: true

module Everyday
  class TravelBudgetCalculator
    attr_reader :errors

    BREAKDOWN = {
      accommodation: 0.40,
      food: 0.25,
      transport: 0.15,
      activities: 0.20
    }.freeze

    def initialize(daily_budget_per_person:, num_days:, num_travelers:)
      @daily_budget_per_person = daily_budget_per_person.to_f
      @num_days = num_days.to_i
      @num_travelers = num_travelers.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      daily_total = @daily_budget_per_person * @num_travelers
      trip_total = daily_total * @num_days

      {
        valid: true,
        daily_total: daily_total.round(2),
        trip_total: trip_total.round(2),
        accommodation: (trip_total * BREAKDOWN[:accommodation]).round(2),
        food: (trip_total * BREAKDOWN[:food]).round(2),
        transport: (trip_total * BREAKDOWN[:transport]).round(2),
        activities: (trip_total * BREAKDOWN[:activities]).round(2)
      }
    end

    private

    def validate!
      @errors << "Daily budget per person must be greater than zero" unless @daily_budget_per_person.positive?
      @errors << "Number of days must be at least 1" unless @num_days >= 1
      @errors << "Number of travelers must be at least 1" unless @num_travelers >= 1
    end
  end
end
