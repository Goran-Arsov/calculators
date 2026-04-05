# frozen_string_literal: true

module Everyday
  class CostPerHourCalculator
    attr_reader :errors

    def initialize(total_cost:, number_of_hours:)
      @total_cost = total_cost.to_f
      @number_of_hours = number_of_hours.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_per_hour = @total_cost / @number_of_hours
      cost_per_minute = cost_per_hour / 60.0
      cost_per_day = cost_per_hour * 24
      cost_per_8_hours = cost_per_hour * 8

      {
        valid: true,
        cost_per_hour: cost_per_hour.round(2),
        cost_per_minute: cost_per_minute.round(4),
        cost_per_day: cost_per_day.round(2),
        cost_per_8_hours: cost_per_8_hours.round(2),
        total_cost: @total_cost.round(2),
        number_of_hours: @number_of_hours.round(2)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Number of hours must be greater than zero" unless @number_of_hours.positive?
    end
  end
end
