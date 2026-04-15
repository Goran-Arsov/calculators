# frozen_string_literal: true

module Construction
  class AsphaltCalculator
    attr_reader :errors

    # Hot-mix asphalt unit weight varies with aggregate and mix design.
    # 145 lb/ft³ is the industry default for dense-graded HMA used on
    # driveways and roads. Open-graded mixes run ~120 lb/ft³.
    DEFAULT_DENSITY_LB_PER_CUFT = 145.0
    POUNDS_PER_US_TON = 2000.0
    TRUCK_TONS_DEFAULT = 20.0

    def initialize(length_ft:, width_ft:, depth_in:, density_lb_per_cuft: DEFAULT_DENSITY_LB_PER_CUFT)
      @length_ft = length_ft.to_f
      @width_ft = width_ft.to_f
      @depth_in = depth_in.to_f
      @density = density_lb_per_cuft.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      depth_ft = @depth_in / 12.0
      cubic_feet = @length_ft * @width_ft * depth_ft
      cubic_yards = cubic_feet / 27.0
      pounds = cubic_feet * @density
      us_tons = pounds / POUNDS_PER_US_TON
      truckloads = (us_tons / TRUCK_TONS_DEFAULT).ceil

      {
        valid: true,
        area_sqft: (@length_ft * @width_ft).round(2),
        cubic_feet: cubic_feet.round(2),
        cubic_yards: cubic_yards.round(2),
        pounds: pounds.round(0),
        us_tons: us_tons.round(2),
        truckloads: truckloads
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length_ft.positive?
      @errors << "Width must be greater than zero" unless @width_ft.positive?
      @errors << "Depth must be greater than zero" unless @depth_in.positive?
      @errors << "Density must be greater than zero" unless @density.positive?
    end
  end
end
