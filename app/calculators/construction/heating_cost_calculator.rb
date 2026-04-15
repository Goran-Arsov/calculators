# frozen_string_literal: true

module Construction
  class HeatingCostCalculator
    attr_reader :errors

    # Annual heating cost from design heat loss, heating degree days (HDD),
    # fuel type, and equipment efficiency.
    #
    # Annual heating energy (BTU) = heat_loss_btu_hr × 24 × HDD / design_dT
    # Then divide by (fuel_energy × efficiency) to get fuel consumption,
    # multiply by unit cost for annual cost.
    #
    # HDD definition: the number of degrees a day's mean temperature falls
    # below 65 °F, summed over the heating season. A day averaging 40 °F
    # contributes 25 HDD. A typical US heating season has 3,000-8,000 HDD.
    FUELS = {
      "natural_gas" => { label: "Natural gas",    btu_per_unit: 100_000, unit: "therm" },
      "propane"     => { label: "Propane",        btu_per_unit: 91_500,  unit: "gallon" },
      "oil"         => { label: "Heating oil #2", btu_per_unit: 138_500, unit: "gallon" },
      "electric"    => { label: "Electric",       btu_per_unit: 3_412,   unit: "kWh" },
      "wood"        => { label: "Wood (hardwood)", btu_per_unit: 24_000_000, unit: "cord" },
      "pellet"      => { label: "Wood pellets",   btu_per_unit: 16_000_000, unit: "ton" }
    }.freeze

    def initialize(heat_loss_btu_hr:, hdd:, design_dt:, fuel:, efficiency:, fuel_cost:)
      @heat_loss = heat_loss_btu_hr.to_f
      @hdd = hdd.to_f
      @design_dt = design_dt.to_f
      @fuel = fuel.to_s.downcase
      @efficiency = efficiency.to_f
      @fuel_cost = fuel_cost.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fuel_info = FUELS[@fuel]

      # Annual heating energy required (BTU). The standard approximation
      # scales heat loss at design temperature by HDD / design_dT.
      annual_btu = @heat_loss * 24.0 * @hdd / @design_dt
      annual_output_btu = annual_btu
      fuel_input_btu = annual_output_btu / (@efficiency / 100.0)
      fuel_units = fuel_input_btu / fuel_info[:btu_per_unit]
      annual_cost = fuel_units * @fuel_cost

      # Per-BTU metrics for comparison
      cost_per_million_btu = annual_cost * 1_000_000.0 / annual_output_btu

      {
        valid: true,
        fuel_label: fuel_info[:label],
        fuel_unit: fuel_info[:unit],
        annual_output_btu: annual_output_btu.round(0),
        annual_output_kwh: (annual_output_btu / 3412).round(0),
        fuel_units: fuel_units.round(2),
        annual_cost: annual_cost.round(2),
        cost_per_million_btu: cost_per_million_btu.round(2)
      }
    end

    private

    def validate!
      @errors << "Heat loss must be greater than zero" unless @heat_loss.positive?
      @errors << "Heating degree days must be greater than zero" unless @hdd.positive?
      @errors << "Design ΔT must be greater than zero" unless @design_dt.positive?
      @errors << "Efficiency must be between 1 and 400 percent" unless (1.0..400.0).cover?(@efficiency)
      @errors << "Fuel cost cannot be negative" if @fuel_cost.negative?
      @errors << "Fuel must be one of #{FUELS.keys.join(', ')}" unless FUELS.key?(@fuel)
    end
  end
end
