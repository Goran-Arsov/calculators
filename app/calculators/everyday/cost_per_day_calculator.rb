# frozen_string_literal: true

module Everyday
  class CostPerDayCalculator
    attr_reader :errors

    def initialize(total_cost:, number_of_days:)
      @total_cost = total_cost.to_f
      @number_of_days = number_of_days.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      cost_per_day = @total_cost / @number_of_days
      cost_per_week = cost_per_day * 7
      cost_per_month = cost_per_day * 30.4375
      cost_per_year = cost_per_day * 365.25

      {
        cost_per_day: cost_per_day.round(2),
        cost_per_week: cost_per_week.round(2),
        cost_per_month: cost_per_month.round(2),
        cost_per_year: cost_per_year.round(2),
        total_cost: @total_cost.round(2),
        number_of_days: @number_of_days.round(1)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Number of days must be greater than zero" unless @number_of_days.positive?
    end
  end
end
