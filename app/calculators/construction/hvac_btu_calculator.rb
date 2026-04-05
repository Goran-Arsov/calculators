# frozen_string_literal: true

module Construction
  class HvacBtuCalculator
    attr_reader :errors

    BASE_BTU_PER_SQFT = 20  # baseline for moderate climate

    # Climate zone multipliers
    CLIMATE_MULTIPLIERS = {
      "hot"      => 1.20,
      "warm"     => 1.10,
      "moderate" => 1.00,
      "cool"     => 0.95,
      "cold"     => 0.90
    }.freeze

    # Insulation quality adjustments
    INSULATION_MULTIPLIERS = {
      "poor"    => 1.30,
      "average" => 1.00,
      "good"    => 0.85
    }.freeze

    # Each window adds BTU load
    BTU_PER_WINDOW = 1_000

    # Ceiling height adjustment (baseline 8 ft)
    BASELINE_CEILING_HEIGHT = 8.0

    def initialize(room_sqft:, ceiling_height: 8, insulation: "average", climate_zone: "moderate", windows: 2)
      @room_sqft = room_sqft.to_f
      @ceiling_height = ceiling_height.to_f
      @insulation = insulation.to_s.downcase.strip
      @climate_zone = climate_zone.to_s.downcase.strip
      @windows = windows.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      # Base BTU from square footage
      base_btu = @room_sqft * BASE_BTU_PER_SQFT

      # Ceiling height adjustment (proportional to volume)
      ceiling_factor = @ceiling_height / BASELINE_CEILING_HEIGHT
      adjusted_btu = base_btu * ceiling_factor

      # Climate zone
      climate_mult = CLIMATE_MULTIPLIERS.fetch(@climate_zone, 1.0)
      adjusted_btu *= climate_mult

      # Insulation quality
      insulation_mult = INSULATION_MULTIPLIERS.fetch(@insulation, 1.0)
      adjusted_btu *= insulation_mult

      # Window heat gain/loss
      window_btu = @windows * BTU_PER_WINDOW
      total_btu = adjusted_btu + window_btu

      # Round to nearest 1,000
      recommended_btu = (total_btu / 1_000.0).ceil * 1_000

      # Tonnage (1 ton = 12,000 BTU)
      tonnage = recommended_btu / 12_000.0

      {
        valid: true,
        base_btu: base_btu.round(0),
        ceiling_factor: ceiling_factor.round(2),
        climate_multiplier: climate_mult,
        insulation_multiplier: insulation_mult,
        window_btu: window_btu,
        total_btu: total_btu.round(0),
        recommended_btu: recommended_btu,
        tonnage: tonnage.round(2)
      }
    end

    private

    def validate!
      @errors << "Room square footage must be greater than zero" unless @room_sqft.positive?
      @errors << "Ceiling height must be greater than zero" unless @ceiling_height.positive?
      unless INSULATION_MULTIPLIERS.key?(@insulation)
        @errors << "Insulation must be one of: poor, average, good"
      end
      unless CLIMATE_MULTIPLIERS.key?(@climate_zone)
        @errors << "Climate zone must be one of: hot, warm, moderate, cool, cold"
      end
      @errors << "Windows cannot be negative" if @windows.negative?
    end
  end
end
