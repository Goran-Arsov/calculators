# frozen_string_literal: true

module Gardening
  class CompostCalculator
    include GardenDimensionInput

    attr_reader :errors

    CUBIC_FEET_PER_YARD = 27.0
    BAG_CUBIC_FEET = 1.0
    POUNDS_PER_CUBIC_FOOT = 45.0
    KG_PER_POUND = 0.45359237

    def initialize(length_ft: nil, width_ft: nil, depth_in: nil,
                   length_m: nil, width_m: nil, depth_cm: nil,
                   unit_system: nil)
      @unit_system = detect_unit_system(unit_system, length_m, width_m, depth_cm)
      @length_ft = to_feet(length_ft, length_m)
      @width_ft = to_feet(width_ft, width_m)
      @depth_in = to_inches(depth_in, depth_cm)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_sqft = @length_ft * @width_ft
      cubic_feet = area_sqft * (@depth_in / 12.0)
      pounds = cubic_feet * POUNDS_PER_CUBIC_FOOT

      with_metric_dimensions(
        valid: true,
        unit_system: @unit_system,
        area_sqft: area_sqft.round(2),
        cubic_feet: cubic_feet.round(2),
        cubic_yards: (cubic_feet / CUBIC_FEET_PER_YARD).round(2),
        pounds: pounds.round(0),
        kilograms: (pounds * KG_PER_POUND).round(1),
        bags: (cubic_feet / BAG_CUBIC_FEET).ceil
      )
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Depth must be greater than zero" unless @depth_in.positive?
    end
  end
end
