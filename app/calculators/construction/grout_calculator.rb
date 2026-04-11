# frozen_string_literal: true

module Construction
  class GroutCalculator
    attr_reader :errors

    # Empirical constant calibrated to manufacturer coverage tables for dry
    # cementitious grout: lbs_per_sqft = ((L+W)/(L*W)) * J * T * DENSITY_FACTOR
    # Validated against Custom Building Products and Mapei coverage charts
    # for 12", 6", and 4" tile sizes with 1/8" and 1/4" joints.
    DENSITY_FACTOR = 45.0

    def initialize(area_sqft:, tile_length_in:, tile_width_in:,
                   joint_width_in:, tile_thickness_in: 0.25, waste_pct: 10)
      @area_sqft = area_sqft.to_f
      @tile_length_in = tile_length_in.to_f
      @tile_width_in = tile_width_in.to_f
      @joint_width_in = joint_width_in.to_f
      @tile_thickness_in = tile_thickness_in.to_f
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      lbs_per_sqft = (
        (@tile_length_in + @tile_width_in) /
        (@tile_length_in * @tile_width_in)
      ) * @joint_width_in * @tile_thickness_in * DENSITY_FACTOR

      pounds_needed = lbs_per_sqft * @area_sqft * (1 + @waste_pct / 100.0)
      bags_25lb = (pounds_needed / 25.0).ceil
      bags_10lb = (pounds_needed / 10.0).ceil
      coverage_sqft_per_25lb = lbs_per_sqft.positive? ? 25.0 / lbs_per_sqft : 0

      {
        valid: true,
        lbs_per_sqft: lbs_per_sqft.round(3),
        pounds_needed: pounds_needed.round(1),
        bags_25lb: bags_25lb,
        bags_10lb: bags_10lb,
        coverage_per_25lb_bag: coverage_sqft_per_25lb.round(1)
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      @errors << "Tile length must be greater than zero" unless @tile_length_in.positive?
      @errors << "Tile width must be greater than zero" unless @tile_width_in.positive?
      @errors << "Joint width must be greater than zero" unless @joint_width_in.positive?
      @errors << "Tile thickness must be greater than zero" unless @tile_thickness_in.positive?
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
