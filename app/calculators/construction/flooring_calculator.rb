# frozen_string_literal: true

module Construction
  class FlooringCalculator
    attr_reader :errors

    BOX_COVERAGE_SQFT = 20

    def initialize(length:, width:, waste_pct: 10)
      @length = length.to_f
      @width = width.to_f
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      area_sqft = @length * @width
      area_with_waste = area_sqft * (1 + @waste_pct / 100.0)
      boxes_needed = (area_with_waste / BOX_COVERAGE_SQFT.to_f).ceil

      {
        area_sqft: area_sqft.round(2),
        area_with_waste: area_with_waste.round(2),
        boxes_needed: boxes_needed
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length.positive?
      @errors << "Width must be greater than zero" unless @width.positive?
      @errors << "Waste percentage cannot be negative" if @waste_pct.negative?
    end
  end
end
