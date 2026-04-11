# frozen_string_literal: true

module Gardening
  class LawnWateringCalculator
    attr_reader :errors

    # 1 inch of water over 1 sqft = 0.6234 US gallons
    GALLONS_PER_SQFT_INCH = 0.6234
    LITERS_PER_GALLON = 3.78541

    def initialize(area_sqft:, inches_per_week: 1.0, sprinkler_gpm: nil)
      @area_sqft = area_sqft.to_f
      @inches_per_week = inches_per_week.to_f
      @sprinkler_gpm = sprinkler_gpm.to_f if sprinkler_gpm && sprinkler_gpm.to_s != ""
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gallons_per_week = @area_sqft * @inches_per_week * GALLONS_PER_SQFT_INCH
      liters_per_week = gallons_per_week * LITERS_PER_GALLON
      minutes_required = @sprinkler_gpm && @sprinkler_gpm.positive? ? gallons_per_week / @sprinkler_gpm : nil

      {
        valid: true,
        gallons_per_week: gallons_per_week.round(1),
        liters_per_week: liters_per_week.round(1),
        gallons_per_day: (gallons_per_week / 7.0).round(1),
        sprinkler_minutes_per_week: minutes_required&.round(0)
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      @errors << "Inches per week must be greater than zero" unless @inches_per_week.positive?
    end
  end
end
