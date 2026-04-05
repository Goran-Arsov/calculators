# frozen_string_literal: true

module Construction
  class TileCalculator
    attr_reader :errors

    GROUT_COVERAGE_SQFT_PER_LB = 9    # ~9 sq ft per lb for 12x12 tiles, 1/8" joint
    ADHESIVE_COVERAGE_SQFT_PER_BAG = 60 # thin-set mortar ~60 sq ft per 50-lb bag

    def initialize(area_sqft:, tile_length_in:, tile_width_in:, grout_width_in: 0.125, waste_pct: 10)
      @area_sqft = area_sqft.to_f
      @tile_length_in = tile_length_in.to_f
      @tile_width_in = tile_width_in.to_f
      @grout_width_in = grout_width_in.to_f
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Tile area in square feet (including grout line around each tile)
      tile_area_in = @tile_length_in * @tile_width_in
      tile_area_sqft = tile_area_in / 144.0

      # Effective tile area with grout
      effective_length = @tile_length_in + @grout_width_in
      effective_width = @tile_width_in + @grout_width_in
      effective_area_sqft = (effective_length * effective_width) / 144.0

      # Tiles needed
      area_with_waste = @area_sqft * (1 + @waste_pct / 100.0)
      tiles_needed = (area_with_waste / effective_area_sqft).ceil

      # Grout: estimate based on joint volume
      # Linear feet of grout joints per sq ft
      tiles_per_sqft = 1.0 / effective_area_sqft
      # Perimeter of grout per tile (2 edges counted, other 2 shared)
      grout_linear_in_per_tile = @tile_length_in + @tile_width_in
      total_grout_linear_ft = (tiles_needed * grout_linear_in_per_tile) / 12.0
      # Cross-sectional area of grout joint (width x depth assumed = tile thickness ~0.25")
      grout_depth_in = 0.25
      grout_volume_cuin = total_grout_linear_ft * 12.0 * @grout_width_in * grout_depth_in
      grout_lbs = (grout_volume_cuin / 13.5).ceil  # ~13.5 cu in per lb of sanded grout
      grout_lbs = [ grout_lbs, 1 ].max

      # Adhesive (thin-set mortar bags)
      adhesive_bags = (area_with_waste / ADHESIVE_COVERAGE_SQFT_PER_BAG.to_f).ceil

      {
        valid: true,
        area_sqft: @area_sqft.round(2),
        area_with_waste: area_with_waste.round(2),
        tile_area_sqft: tile_area_sqft.round(2),
        tiles_needed: tiles_needed,
        grout_lbs: grout_lbs,
        adhesive_bags: adhesive_bags
      }
    end

    private

    def validate!
      @errors << "Area must be greater than zero" unless @area_sqft.positive?
      @errors << "Tile length must be greater than zero" unless @tile_length_in.positive?
      @errors << "Tile width must be greater than zero" unless @tile_width_in.positive?
      @errors << "Grout width cannot be negative" if @grout_width_in.negative?
      @errors << "Waste percentage cannot be negative" if @waste_pct.negative?
    end
  end
end
