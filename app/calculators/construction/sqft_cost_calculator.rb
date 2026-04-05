# frozen_string_literal: true

module Construction
  class SqftCostCalculator
    attr_reader :errors

    SQFT_PER_SQM = 10.7639
    SQFT_PER_ACRE = 43_560.0

    def initialize(total_cost:, area_sqft:)
      @total_cost = total_cost.to_f
      @area_sqft = area_sqft.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_per_sqft = @total_cost / @area_sqft
      area_sqm = @area_sqft / SQFT_PER_SQM
      cost_per_sqm = @total_cost / area_sqm
      area_acres = @area_sqft / SQFT_PER_ACRE
      cost_per_acre = @total_cost / area_acres

      {
        valid: true,
        cost_per_sqft: cost_per_sqft.round(2),
        cost_per_sqm: cost_per_sqm.round(2),
        cost_per_acre: cost_per_acre.round(2),
        area_sqft: @area_sqft.round(2),
        area_sqm: area_sqm.round(2),
        area_acres: area_acres.round(4)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
    end
  end
end
