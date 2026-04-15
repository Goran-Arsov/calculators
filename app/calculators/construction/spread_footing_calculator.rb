# frozen_string_literal: true

module Construction
  class SpreadFootingCalculator
    attr_reader :errors

    # Typical allowable soil bearing capacity (psf) for residential foundations.
    # IBC Table 1806.2 presumptive values — use the actual geotech report
    # whenever possible.
    DEFAULT_BEARING_PSF = {
      "sandy_clay" => 2000,
      "clay"       => 1500,
      "sand"       => 2000,
      "gravel"     => 3000,
      "rock"       => 12000
    }.freeze

    # IRC minimum footing dimensions for deck / small column footings.
    MIN_FOOTING_SIDE_IN = 8.0
    MIN_FOOTING_DEPTH_IN = 8.0

    def initialize(column_load_lbs:, bearing_psf:, safety_factor: 1.0, min_depth_in: MIN_FOOTING_DEPTH_IN)
      @load_lbs = column_load_lbs.to_f
      @bearing_psf = bearing_psf.to_f
      @safety_factor = safety_factor.to_f
      @min_depth_in = min_depth_in.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Required area (sq ft) = load × SF / allowable bearing
      required_area_sqft = (@load_lbs * @safety_factor) / @bearing_psf
      # Convert area to a square footing side length
      side_in_raw = Math.sqrt(required_area_sqft) * 12.0
      side_in = [ side_in_raw, MIN_FOOTING_SIDE_IN ].max
      # Round up to nearest 2-inch increment for practical formwork
      side_in_rounded = (side_in / 2.0).ceil * 2.0

      # Round column diameter equivalent (same area as square)
      diameter_in_raw = 2.0 * Math.sqrt(required_area_sqft * 144.0 / Math::PI)
      diameter_in = [ diameter_in_raw, MIN_FOOTING_SIDE_IN ].max

      depth_in = [ @min_depth_in, MIN_FOOTING_DEPTH_IN ].max

      # Concrete volume for the square footing
      concrete_cuft = (side_in_rounded / 12.0)**2 * (depth_in / 12.0)
      concrete_cuyd = concrete_cuft / 27.0

      {
        valid: true,
        required_area_sqft: required_area_sqft.round(3),
        required_area_sqin: (required_area_sqft * 144).round(2),
        square_side_in: side_in_rounded.round(1),
        round_diameter_in: diameter_in.round(1),
        depth_in: depth_in.round(1),
        concrete_cuft: concrete_cuft.round(2),
        concrete_cuyd: concrete_cuyd.round(3),
        actual_bearing_psf: (@load_lbs / ((side_in_rounded / 12.0)**2)).round(0)
      }
    end

    private

    def validate!
      @errors << "Column load must be greater than zero" unless @load_lbs.positive?
      @errors << "Bearing capacity must be greater than zero" unless @bearing_psf.positive?
      @errors << "Safety factor must be at least 1.0" if @safety_factor < 1.0
      @errors << "Minimum depth must be at least zero" if @min_depth_in.negative?
    end
  end
end
