# frozen_string_literal: true

module Construction
  class PoolVolumeCalculator
    attr_reader :errors

    GALLONS_PER_CUBIC_FOOT = 7.48052
    LITERS_PER_GALLON = 3.78541
    SHAPES = %w[rectangular round oval kidney].freeze

    # Shape volume multipliers applied to bounding-box area × depth.
    # Round uses exact π/4 fill ratio; oval uses π/4 as well (ellipse is
    # (π/4) × major × minor); kidney is an empirical 0.85 fill factor.
    SHAPE_FACTORS = {
      "rectangular" => 1.0,
      "round" => Math::PI / 4.0,
      "oval" => Math::PI / 4.0,
      "kidney" => 0.85
    }.freeze

    def initialize(shape:, length_ft:, width_ft:, average_depth_ft:)
      @shape = shape.to_s
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @average_depth_ft = average_depth_ft.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      footprint = @length_ft * @width_ft * SHAPE_FACTORS[@shape]
      cubic_feet = footprint * @average_depth_ft
      gallons = cubic_feet * GALLONS_PER_CUBIC_FOOT
      liters = gallons * LITERS_PER_GALLON

      {
        valid: true,
        surface_area_sqft: footprint.round(2),
        cubic_feet: cubic_feet.round(2),
        gallons: gallons.round(0),
        liters: liters.round(0),
        shape: @shape
      }
    end

    private

    def validate!
      @errors << "Shape must be one of: #{SHAPES.join(', ')}" unless SHAPES.include?(@shape)
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Average depth must be greater than zero" unless @average_depth_ft.positive?
    end
  end
end
