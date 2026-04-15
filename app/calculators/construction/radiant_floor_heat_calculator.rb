# frozen_string_literal: true

module Construction
  class RadiantFloorHeatCalculator
    attr_reader :errors

    # Simplified hydronic radiant floor calculator.
    #
    # PEX tube length (ft) per sq ft of floor ≈ 12 / spacing_in + allowance.
    # Typical practical values:
    #   6" OC spacing  → 2.0 ft of tube per sq ft
    #   9" OC spacing  → 1.33 ft per sq ft
    #   12" OC spacing → 1.0 ft per sq ft
    #
    # BTU/hr output varies with mean water temp, floor surface resistance,
    # and room temp. Rules of thumb for 1/2" PEX at 110-120 °F water:
    #   Bare concrete:     30-35 BTU/hr per sq ft
    #   Tile or stone:     25-30 BTU/hr per sq ft
    #   Wood over slab:    20-25 BTU/hr per sq ft
    #   Carpet w/ pad:     12-15 BTU/hr per sq ft (discouraged)
    BTU_PER_SQFT = {
      "concrete" => 32,
      "tile"     => 27,
      "wood"     => 22,
      "carpet"   => 14
    }.freeze

    SPACING_FACTOR = {
      6  => 2.0,
      9  => 1.33,
      12 => 1.0
    }.freeze

    # Practical loop length limits for 1/2" PEX to stay under ~40 ft head loss.
    MAX_LOOP_LENGTH_FT = {
      "3/8" => 200,
      "1/2" => 300,
      "5/8" => 400
    }.freeze

    def initialize(area_sqft:, spacing_in: 12, surface: "tile", tube_size: "1/2")
      @area = area_sqft.to_f
      @spacing = spacing_in.to_i
      @surface = surface.to_s.downcase
      @tube_size = tube_size.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tube_per_sqft = SPACING_FACTOR[@spacing]
      total_tube = @area * tube_per_sqft
      # Add 10% for bends and headers
      total_tube_with_waste = total_tube * 1.10
      max_loop_ft = MAX_LOOP_LENGTH_FT[@tube_size]
      loop_count = (total_tube_with_waste / max_loop_ft).ceil
      loop_count = 1 if loop_count < 1
      length_per_loop = total_tube_with_waste / loop_count

      btu_per_sqft = BTU_PER_SQFT[@surface]
      total_btu = @area * btu_per_sqft
      watts = total_btu / 3.412

      {
        valid: true,
        area_sqft: @area.round(2),
        tube_per_sqft: tube_per_sqft,
        total_tube_ft: total_tube_with_waste.round(0),
        loop_count: loop_count,
        length_per_loop_ft: length_per_loop.round(0),
        max_loop_ft: max_loop_ft,
        btu_per_sqft: btu_per_sqft,
        total_btu_hr: total_btu.round(0),
        total_watts: watts.round(0),
        total_kw: (watts / 1000.0).round(2)
      }
    end

    private

    def validate!
      @errors << "Floor area must be greater than zero" unless @area.positive?
      @errors << "Spacing must be 6, 9, or 12 inches" unless SPACING_FACTOR.key?(@spacing)
      @errors << "Surface must be concrete, tile, wood, or carpet" unless BTU_PER_SQFT.key?(@surface)
      @errors << "Tube size must be 3/8, 1/2, or 5/8" unless MAX_LOOP_LENGTH_FT.key?(@tube_size)
    end
  end
end
