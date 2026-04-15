# frozen_string_literal: true

module Construction
  class ChimneyFlueCalculator
    attr_reader :errors

    # Simplified flue sizing based on NFPA 211 / manufacturer recommendations:
    # required flue cross-section area (sq in) ≈ BTU/hr ÷ btu_per_sqin
    # Different appliance types need different flue area per BTU:
    #   wood stove / fireplace insert: 30,000 BTU/hr per sq in
    #   gas appliance (Category I draft hood): 75,000 BTU/hr per sq in
    #   oil furnace / boiler:                  40,000 BTU/hr per sq in
    # These are intentionally conservative and for preliminary sizing only.
    BTU_PER_SQIN = {
      "wood"  => 30_000,
      "gas"   => 75_000,
      "oil"   => 40_000,
      "pellet" => 50_000
    }.freeze

    # Minimum chimney heights by appliance (ft above the roof).
    MIN_HEIGHT_FT = {
      "wood"  => 15.0,
      "gas"   => 5.0,
      "oil"   => 10.0,
      "pellet" => 10.0
    }.freeze

    def initialize(btu_hr:, appliance: "wood")
      @btu_hr = btu_hr.to_f
      @appliance = appliance.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      btu_per_sqin = BTU_PER_SQIN[@appliance]
      required_area_sqin = @btu_hr / btu_per_sqin
      round_diameter_in = 2.0 * Math.sqrt(required_area_sqin / Math::PI)
      square_side_in = Math.sqrt(required_area_sqin)
      min_height_ft = MIN_HEIGHT_FT[@appliance]

      # Round up to nearest commercial size
      commercial_round = [ 6, 7, 8, 10, 12, 14, 16, 18, 20, 24 ].find { |d| d >= round_diameter_in } || 24

      {
        valid: true,
        required_area_sqin: required_area_sqin.round(2),
        round_diameter_in: round_diameter_in.round(2),
        square_side_in: square_side_in.round(2),
        commercial_round_in: commercial_round,
        min_height_ft: min_height_ft,
        btu_per_sqin_used: btu_per_sqin
      }
    end

    private

    def validate!
      @errors << "BTU/hr must be greater than zero" unless @btu_hr.positive?
      @errors << "Appliance must be wood, gas, oil, or pellet" unless BTU_PER_SQIN.key?(@appliance)
    end
  end
end
