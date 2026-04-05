# frozen_string_literal: true

module Construction
  class RoofingCalculator
    attr_reader :errors

    SHINGLES_PER_SQUARE = 3   # 3 bundles per square (100 sq ft)
    SQUARE_SQFT = 100
    FELT_ROLL_SQFT = 400      # 15-lb felt roll covers ~400 sq ft
    NAILS_PER_SQUARE = 320    # ~320 roofing nails per square
    NAILS_PER_BOX = 250       # standard box of roofing nails

    # Roof pitch multipliers: pitch (rise/12) → area multiplier
    PITCH_MULTIPLIERS = {
      0  => 1.000,
      1  => 1.003,
      2  => 1.014,
      3  => 1.031,
      4  => 1.054,
      5  => 1.083,
      6  => 1.118,
      7  => 1.158,
      8  => 1.202,
      9  => 1.250,
      10 => 1.302,
      11 => 1.357,
      12 => 1.414
    }.freeze

    def initialize(length:, width:, pitch:, waste_pct: 10)
      @length = length.to_f
      @width = width.to_f
      @pitch = pitch.to_i
      @waste_pct = waste_pct.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      # Calculate roof area using pitch multiplier
      footprint_area = @length * @width
      multiplier = PITCH_MULTIPLIERS.fetch(@pitch) { Math.sqrt(1 + (@pitch / 12.0)**2) }
      roof_area = footprint_area * multiplier
      area_with_waste = roof_area * (1 + @waste_pct / 100.0)

      # Roofing squares (1 square = 100 sq ft)
      squares = (area_with_waste / SQUARE_SQFT.to_f).ceil

      # Bundles of shingles (3 bundles per square)
      bundles = squares * SHINGLES_PER_SQUARE

      # Felt underlayment rolls
      felt_rolls = (area_with_waste / FELT_ROLL_SQFT.to_f).ceil

      # Roofing nails (boxes)
      total_nails = squares * NAILS_PER_SQUARE
      nail_boxes = (total_nails / NAILS_PER_BOX.to_f).ceil

      {
        footprint_area: footprint_area.round(2),
        roof_area: roof_area.round(2),
        area_with_waste: area_with_waste.round(2),
        squares: squares,
        bundles: bundles,
        felt_rolls: felt_rolls,
        nail_boxes: nail_boxes
      }
    end

    private

    def validate!
      @errors << "Length must be greater than zero" unless @length.positive?
      @errors << "Width must be greater than zero" unless @width.positive?
      @errors << "Pitch must be between 0 and 12" unless @pitch >= 0 && @pitch <= 12
      @errors << "Waste percentage cannot be negative" if @waste_pct.negative?
    end
  end
end
