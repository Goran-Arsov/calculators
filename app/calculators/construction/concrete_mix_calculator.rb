# frozen_string_literal: true

module Construction
  class ConcreteMixCalculator
    attr_reader :errors

    # Mix ratios by target PSI: cement : sand : gravel (by volume)
    MIX_RATIOS = {
      2500 => { cement: 1.0, sand: 2.5, gravel: 3.5, water_cement_ratio: 0.65, label: "General purpose" },
      3000 => { cement: 1.0, sand: 2.0, gravel: 3.0, water_cement_ratio: 0.55, label: "Standard residential" },
      3500 => { cement: 1.0, sand: 1.75, gravel: 2.75, water_cement_ratio: 0.50, label: "Driveways & sidewalks" },
      4000 => { cement: 1.0, sand: 1.5, gravel: 2.5, water_cement_ratio: 0.45, label: "Structural / commercial" },
      4500 => { cement: 1.0, sand: 1.25, gravel: 2.25, water_cement_ratio: 0.40, label: "Heavy-duty structural" },
      5000 => { cement: 1.0, sand: 1.0, gravel: 2.0, water_cement_ratio: 0.35, label: "High-strength" }
    }.freeze

    CEMENT_WEIGHT_PER_CUFT = 94.0  # lbs per cubic foot (1 bag)
    SAND_WEIGHT_PER_CUFT = 100.0
    GRAVEL_WEIGHT_PER_CUFT = 105.0
    WATER_WEIGHT_PER_CUFT = 62.4
    CUBIC_FT_PER_YARD = 27.0

    def initialize(target_psi:, volume_cubic_yards: 1.0)
      @target_psi = target_psi.to_i
      @volume_cubic_yards = volume_cubic_yards.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      mix = MIX_RATIOS[@target_psi]
      total_parts = mix[:cement] + mix[:sand] + mix[:gravel]
      volume_cuft = @volume_cubic_yards * CUBIC_FT_PER_YARD

      cement_cuft = (mix[:cement] / total_parts) * volume_cuft
      sand_cuft = (mix[:sand] / total_parts) * volume_cuft
      gravel_cuft = (mix[:gravel] / total_parts) * volume_cuft
      water_cuft = cement_cuft * mix[:water_cement_ratio]

      cement_lbs = (cement_cuft * CEMENT_WEIGHT_PER_CUFT).round(0)
      sand_lbs = (sand_cuft * SAND_WEIGHT_PER_CUFT).round(0)
      gravel_lbs = (gravel_cuft * GRAVEL_WEIGHT_PER_CUFT).round(0)
      water_gallons = (water_cuft * 7.48).round(1)

      cement_bags_94lb = (cement_lbs / 94.0).ceil

      {
        valid: true,
        target_psi: @target_psi,
        label: mix[:label],
        ratio_cement: mix[:cement],
        ratio_sand: mix[:sand],
        ratio_gravel: mix[:gravel],
        water_cement_ratio: mix[:water_cement_ratio],
        cement_lbs: cement_lbs,
        sand_lbs: sand_lbs,
        gravel_lbs: gravel_lbs,
        water_gallons: water_gallons,
        cement_bags_94lb: cement_bags_94lb,
        total_volume_cuft: volume_cuft.round(1)
      }
    end

    private

    def validate!
      @errors << "Volume must be greater than zero" unless @volume_cubic_yards.positive?
      @errors << "Target PSI must be one of: #{MIX_RATIOS.keys.join(', ')}" unless MIX_RATIOS.key?(@target_psi)
    end
  end
end
