# frozen_string_literal: true

module Construction
  class PricePerSqmCalculator
    attr_reader :errors

    SQFT_PER_SQM = 10.7639
    SQM_PER_ACRE = 4_046.8564224

    def initialize(total_cost:, area:, unit: "sqm")
      @total_cost = total_cost.to_f
      @area = area.to_f
      @unit = unit.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_sqm = @unit == "sqft" ? @area / SQFT_PER_SQM : @area
      area_sqft = @unit == "sqft" ? @area : @area * SQFT_PER_SQM
      area_acres = area_sqm / SQM_PER_ACRE

      price_per_sqm = @total_cost / area_sqm
      price_per_sqft = @total_cost / area_sqft
      price_per_acre = @total_cost / area_acres

      {
        valid: true,
        price_per_sqm: price_per_sqm.round(2),
        price_per_sqft: price_per_sqft.round(2),
        price_per_acre: price_per_acre.round(2),
        area_sqm: area_sqm.round(2),
        area_sqft: area_sqft.round(2),
        area_acres: area_acres.round(4),
        total_cost: @total_cost.round(2)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Area must be greater than zero" unless @area.positive?
      @errors << "Unit must be sqm or sqft" unless %w[sqm sqft].include?(@unit)
    end
  end
end
