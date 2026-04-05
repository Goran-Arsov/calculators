# frozen_string_literal: true

module Everyday
  class FuelCostTripCalculator
    attr_reader :errors

    LITERS_PER_GALLON = 3.78541
    KM_PER_MILE = 1.60934

    def initialize(distance:, fuel_efficiency:, fuel_price:, efficiency_unit: "l_per_100km", distance_unit: "km", price_unit: "per_liter")
      @distance = distance.to_f
      @fuel_efficiency = fuel_efficiency.to_f
      @fuel_price = fuel_price.to_f
      @efficiency_unit = efficiency_unit.to_s.downcase
      @distance_unit = distance_unit.to_s.downcase
      @price_unit = price_unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      distance_km = @distance_unit == "miles" ? @distance * KM_PER_MILE : @distance
      distance_miles = @distance_unit == "miles" ? @distance : @distance / KM_PER_MILE

      # Convert efficiency to L/100km
      l_per_100km = case @efficiency_unit
                    when "l_per_100km" then @fuel_efficiency
                    when "mpg" then LITERS_PER_GALLON * 100.0 / (@fuel_efficiency * KM_PER_MILE)
                    when "km_per_l" then 100.0 / @fuel_efficiency
                    end

      fuel_needed_liters = distance_km * l_per_100km / 100.0
      fuel_needed_gallons = fuel_needed_liters / LITERS_PER_GALLON

      # Convert price to per liter
      price_per_liter = @price_unit == "per_gallon" ? @fuel_price / LITERS_PER_GALLON : @fuel_price

      trip_cost = fuel_needed_liters * price_per_liter

      {
        valid: true,
        trip_cost: trip_cost.round(2),
        fuel_needed_liters: fuel_needed_liters.round(2),
        fuel_needed_gallons: fuel_needed_gallons.round(2),
        distance_km: distance_km.round(2),
        distance_miles: distance_miles.round(2),
        l_per_100km: l_per_100km.round(2),
        cost_per_km: (trip_cost / distance_km).round(4),
        cost_per_mile: (trip_cost / distance_miles).round(4)
      }
    end

    private

    def validate!
      @errors << "Distance must be greater than zero" unless @distance.positive?
      @errors << "Fuel efficiency must be greater than zero" unless @fuel_efficiency.positive?
      @errors << "Fuel price must be greater than zero" unless @fuel_price.positive?
      @errors << "Invalid efficiency unit" unless %w[l_per_100km mpg km_per_l].include?(@efficiency_unit)
      @errors << "Invalid distance unit" unless %w[km miles].include?(@distance_unit)
      @errors << "Invalid price unit" unless %w[per_liter per_gallon].include?(@price_unit)
    end
  end
end
