# frozen_string_literal: true

module Everyday
  class FuelCostCalculator
    attr_reader :errors

    def initialize(distance:, fuel_economy_mpg:, fuel_price_per_gallon:)
      @distance = distance.to_f
      @fuel_economy_mpg = fuel_economy_mpg.to_f
      @fuel_price_per_gallon = fuel_price_per_gallon.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      gallons_needed = @distance / @fuel_economy_mpg
      total_cost = gallons_needed * @fuel_price_per_gallon
      cost_per_mile = total_cost / @distance

      {
        gallons_needed: gallons_needed.round(2),
        total_cost: total_cost.round(2),
        cost_per_mile: cost_per_mile.round(4)
      }
    end

    private

    def validate!
      @errors << "Distance must be greater than zero" unless @distance.positive?
      @errors << "Fuel economy must be greater than zero" unless @fuel_economy_mpg.positive?
      @errors << "Fuel price must be greater than zero" unless @fuel_price_per_gallon.positive?
    end
  end
end
