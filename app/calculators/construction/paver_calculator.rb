# frozen_string_literal: true

module Construction
  class PaverCalculator
    attr_reader :errors

    # Standard patio base spec: 4" compacted aggregate + 1" leveling sand.
    BASE_DEPTH_IN = 4.0
    SAND_DEPTH_IN = 1.0
    CUBIC_FEET_PER_YARD = 27.0
    SQ_IN_PER_SQ_FT = 144.0

    def initialize(patio_length_ft:, patio_width_ft:, paver_length_in:, paver_width_in:, waste_pct: 10.0)
      @patio_length_ft = patio_length_ft.to_f
      @patio_width_ft = patio_width_ft.to_f
      @paver_length_in = paver_length_in.to_f
      @paver_width_in = paver_width_in.to_f
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      patio_area_sqft = @patio_length_ft * @patio_width_ft
      paver_area_sqin = @paver_length_in * @paver_width_in
      paver_area_sqft = paver_area_sqin / SQ_IN_PER_SQ_FT

      pavers_exact = patio_area_sqft / paver_area_sqft
      # Round to 6 decimals before ceil to avoid floating-point drift
      # (e.g. 100 × 1.10 → 110.00000000000001 → ceils to 111).
      pavers_with_waste = (pavers_exact * (1 + @waste_pct / 100)).round(6).ceil

      base_cubic_yards = patio_area_sqft * (BASE_DEPTH_IN / 12.0) / CUBIC_FEET_PER_YARD
      sand_cubic_yards = patio_area_sqft * (SAND_DEPTH_IN / 12.0) / CUBIC_FEET_PER_YARD

      {
        valid: true,
        patio_area_sqft: patio_area_sqft.round(2),
        paver_area_sqin: paver_area_sqin.round(2),
        pavers_exact: pavers_exact.ceil,
        pavers_with_waste: pavers_with_waste,
        base_cubic_yards: base_cubic_yards.round(2),
        sand_cubic_yards: sand_cubic_yards.round(2)
      }
    end

    private

    def validate!
      @errors << "Patio length must be greater than zero" unless @patio_length_ft.positive?
      @errors << "Patio width must be greater than zero" unless @patio_width_ft.positive?
      @errors << "Paver length must be greater than zero" unless @paver_length_in.positive?
      @errors << "Paver width must be greater than zero" unless @paver_width_in.positive?
      @errors << "Waste percent cannot be negative" if @waste_pct.negative?
    end
  end
end
