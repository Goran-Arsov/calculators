# frozen_string_literal: true

module Gardening
  class MulchCalculator
    attr_reader :errors

    CUBIC_FEET_PER_YARD = 27.0
    BAG_CUBIC_FEET = 2.0

    def initialize(length_ft:, width_ft:, depth_in:)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @depth_in = depth_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area_sqft = @length_ft * @width_ft
      cubic_feet = area_sqft * (@depth_in / 12.0)
      cubic_yards = cubic_feet / CUBIC_FEET_PER_YARD
      bags_2cf = (cubic_feet / BAG_CUBIC_FEET).ceil

      {
        valid: true,
        area_sqft: area_sqft.round(2),
        cubic_feet: cubic_feet.round(2),
        cubic_yards: cubic_yards.round(2),
        bags_2cf: bags_2cf
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Depth must be greater than zero" unless @depth_in.positive?
    end
  end
end
