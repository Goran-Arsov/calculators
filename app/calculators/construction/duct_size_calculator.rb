# frozen_string_literal: true

module Construction
  class DuctSizeCalculator
    attr_reader :errors

    # Target velocity presets (fpm) — Manual D recommended residential ranges.
    #   supply trunk:     700-900 fpm
    #   supply branch:    600-700 fpm
    #   return trunk:     500-700 fpm
    # Higher velocity = smaller duct = more noise and static pressure.
    VALID_SHAPES = %w[round rectangular].freeze
    CFM_PER_SQFT = 144.0 # sq in ↔ sq ft

    def initialize(cfm:, velocity_fpm:, shape: "round", aspect_ratio: 2.0)
      @cfm = cfm.to_f
      @velocity_fpm = velocity_fpm.to_f
      @shape = shape.to_s.downcase
      @aspect_ratio = aspect_ratio.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Required area in sq ft = CFM / velocity
      area_sqft = @cfm / @velocity_fpm
      area_sqin = area_sqft * 144.0

      # Round duct: area = π × r²  ⇒ d = 2 × √(area/π)
      round_diameter_in = 2.0 * Math.sqrt(area_sqin / Math::PI)

      # Rectangular duct with fixed aspect ratio (long/short):
      # area = L × S = aspect × S²  ⇒  S = √(area / aspect)
      short_side_in = Math.sqrt(area_sqin / @aspect_ratio)
      long_side_in = short_side_in * @aspect_ratio

      # ASHRAE 2009 equivalent round diameter for rectangular duct:
      # De = 1.30 × (a × b)^0.625 / (a + b)^0.25
      a = long_side_in
      b = short_side_in
      equiv_round_in = 1.30 * ((a * b)**0.625) / ((a + b)**0.25)

      {
        valid: true,
        area_sqft: area_sqft.round(4),
        area_sqin: area_sqin.round(2),
        round_diameter_in: round_diameter_in.round(2),
        rect_long_in: long_side_in.round(2),
        rect_short_in: short_side_in.round(2),
        equivalent_round_in: equiv_round_in.round(2)
      }
    end

    private

    def validate!
      @errors << "CFM must be greater than zero" unless @cfm.positive?
      @errors << "Velocity must be greater than zero" unless @velocity_fpm.positive?
      @errors << "Shape must be round or rectangular" unless VALID_SHAPES.include?(@shape)
      @errors << "Aspect ratio must be at least 1.0" if @aspect_ratio < 1.0
    end
  end
end
