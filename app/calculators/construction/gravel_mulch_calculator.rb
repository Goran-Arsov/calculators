# frozen_string_literal: true

module Construction
  class GravelMulchCalculator
    attr_reader :errors

    CUBIC_FEET_PER_YARD = 27
    GRAVEL_TONS_PER_CUBIC_YARD = 1.4

    def initialize(length_ft:, width_ft:, depth_in:)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @depth_in = depth_in.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      area_sqft = @length_ft * @width_ft
      depth_ft = @depth_in / 12.0
      cubic_feet = @length_ft * @width_ft * depth_ft
      cubic_yards = cubic_feet / CUBIC_FEET_PER_YARD.to_f
      tons = cubic_yards * GRAVEL_TONS_PER_CUBIC_YARD

      {
        cubic_yards: cubic_yards.round(2),
        tons: tons.round(2),
        area_sqft: area_sqft.round(2)
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
