# frozen_string_literal: true

module Gardening
  class FertilizerCalculator
    attr_reader :errors

    def initialize(area_sqft:, nitrogen_rate_per_1000:, fertilizer_n_percent:)
      @area_sqft = area_sqft.to_f
      @nitrogen_rate_per_1000 = nitrogen_rate_per_1000.to_f
      @fertilizer_n_percent = fertilizer_n_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      pounds_of_n = (@area_sqft / 1000.0) * @nitrogen_rate_per_1000
      pounds_fertilizer = pounds_of_n / (@fertilizer_n_percent / 100.0)
      kilos_fertilizer = pounds_fertilizer * 0.453592

      {
        valid: true,
        pounds_of_nitrogen: pounds_of_n.round(2),
        pounds_fertilizer: pounds_fertilizer.round(2),
        kilos_fertilizer: kilos_fertilizer.round(2),
        ounces_fertilizer: (pounds_fertilizer * 16).round(1)
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      @errors << "Nitrogen rate must be greater than zero" unless @nitrogen_rate_per_1000.positive?
      unless @fertilizer_n_percent.positive? && @fertilizer_n_percent <= 100
        @errors << "Fertilizer nitrogen percent must be between 0 and 100"
      end
    end
  end
end
