# frozen_string_literal: true

module Automotive
  class MpgCalculator
    attr_reader :errors

    def initialize(distance:, fuel_used:, unit_system: "imperial")
      @distance = distance.to_f
      @fuel_used = fuel_used.to_f
      @unit_system = unit_system.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @unit_system == "metric"
        liters_per_100km = (@fuel_used / @distance) * 100.0
        km_per_liter = @distance / @fuel_used
        # Convert to imperial equivalents
        mpg = 235.215 / liters_per_100km

        {
          valid: true,
          liters_per_100km: liters_per_100km.round(2),
          km_per_liter: km_per_liter.round(2),
          mpg_equivalent: mpg.round(1),
          distance_km: @distance.round(1),
          fuel_liters: @fuel_used.round(2),
          unit_system: @unit_system
        }
      else
        mpg = @distance / @fuel_used
        cost_per_mile = nil
        # Convert to metric equivalents
        liters_per_100km = 235.215 / mpg

        {
          valid: true,
          mpg: mpg.round(1),
          liters_per_100km_equivalent: liters_per_100km.round(2),
          distance_miles: @distance.round(1),
          fuel_gallons: @fuel_used.round(2),
          unit_system: @unit_system
        }
      end
    end

    private

    def validate!
      @errors << "Distance must be positive" unless @distance > 0
      @errors << "Fuel used must be positive" unless @fuel_used > 0
      unless %w[imperial metric].include?(@unit_system)
        @errors << "Unit system must be imperial or metric"
      end
    end
  end
end
