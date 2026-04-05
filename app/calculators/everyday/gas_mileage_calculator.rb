# frozen_string_literal: true

module Everyday
  class GasMileageCalculator
    attr_reader :errors

    LITERS_PER_GALLON = 3.78541
    KM_PER_MILE = 1.60934

    def initialize(distance:, fuel_used:)
      @distance = distance.to_f
      @fuel_used = fuel_used.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      mpg = @distance / @fuel_used
      l_per_100km = (@fuel_used / @distance) * 100.0
      km_per_l = @distance / @fuel_used

      {
        valid: true,
        mpg: mpg.round(2),
        l_per_100km: l_per_100km.round(2),
        km_per_l: km_per_l.round(2)
      }

    end

    private

    def validate!
      @errors << "Distance must be greater than zero" unless @distance.positive?
      @errors << "Fuel used must be greater than zero" unless @fuel_used.positive?
    end
  end
end
