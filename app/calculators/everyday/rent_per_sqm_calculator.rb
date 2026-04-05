# frozen_string_literal: true

module Everyday
  class RentPerSqmCalculator
    attr_reader :errors

    SQFT_PER_SQM = 10.7639

    def initialize(monthly_rent:, area:, unit: "sqm")
      @monthly_rent = monthly_rent.to_f
      @area = area.to_f
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_sqm = @unit == "sqft" ? @area / SQFT_PER_SQM : @area
      area_sqft = @unit == "sqft" ? @area : @area * SQFT_PER_SQM

      price_per_sqm = @monthly_rent / area_sqm
      price_per_sqft = @monthly_rent / area_sqft
      annual_cost = @monthly_rent * 12

      {
        valid: true,
        price_per_sqm: price_per_sqm.round(2),
        price_per_sqft: price_per_sqft.round(2),
        annual_cost: annual_cost.round(2),
        area_sqm: area_sqm.round(2),
        area_sqft: area_sqft.round(2),
        monthly_rent: @monthly_rent.round(2)
      }
    end

    private

    def validate!
      @errors << "Monthly rent must be greater than zero" unless @monthly_rent.positive?
      @errors << "Area must be greater than zero" unless @area.positive?
      @errors << "Unit must be sqm or sqft" unless %w[sqm sqft].include?(@unit)
    end
  end
end
