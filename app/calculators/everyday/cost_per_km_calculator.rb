# frozen_string_literal: true

module Everyday
  class CostPerKmCalculator
    attr_reader :errors

    KM_PER_MILE = 1.60934

    def initialize(distance_km:, fuel_used_liters:, fuel_price_per_liter:)
      @distance_km = distance_km.to_f
      @fuel_used_liters = fuel_used_liters.to_f
      @fuel_price_per_liter = fuel_price_per_liter.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_fuel_cost = @fuel_used_liters * @fuel_price_per_liter
      cost_per_km = total_fuel_cost / @distance_km
      distance_miles = @distance_km / KM_PER_MILE
      cost_per_mile = total_fuel_cost / distance_miles

      {
        valid: true,
        cost_per_km: cost_per_km.round(4),
        cost_per_mile: cost_per_mile.round(4),
        total_fuel_cost: total_fuel_cost.round(2),
        fuel_used_liters: @fuel_used_liters.round(2),
        distance_miles: distance_miles.round(2)
      }
    end

    private

    def validate!
      @errors << "Distance must be greater than zero" unless @distance_km.positive?
      @errors << "Fuel used must be greater than zero" unless @fuel_used_liters.positive?
      @errors << "Fuel price must be greater than zero" unless @fuel_price_per_liter.positive?
    end
  end
end
