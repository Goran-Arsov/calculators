# frozen_string_literal: true

module Construction
  class KitchenRemodelCalculator
    attr_reader :errors

    # Cost-per-sqft tiers loosely calibrated to Remodeling Magazine's 2024
    # Cost vs. Value Report and HomeAdvisor/Angi national averages. These
    # are rough planning ranges, not bid numbers.
    TIERS = {
      "minor" => { label: "Minor (cosmetic refresh)", per_sqft: 150.0 },
      "midrange" => { label: "Midrange (mid-quality cabinets + counters)", per_sqft: 225.0 },
      "major" => { label: "Major (full remodel, stock cabinets)", per_sqft: 350.0 },
      "luxury" => { label: "Luxury (custom cabinets, high-end finishes)", per_sqft: 550.0 }
    }.freeze

    CUSTOM_CABINET_MULTIPLIER = 1.20
    MOVE_PLUMBING_COST = 2500.0
    MOVE_ELECTRICAL_COST = 1500.0

    BREAKDOWN = {
      cabinets: 0.35,
      appliances: 0.15,
      countertops: 0.15,
      labor: 0.20,
      flooring: 0.07,
      lighting: 0.05,
      other: 0.03
    }.freeze

    def initialize(size_sqft:, tier:, custom_cabinets: false,
                   move_plumbing: false, move_electrical: false)
      @size_sqft = size_sqft.to_f
      @tier = tier.to_s
      @custom_cabinets = custom_cabinets == true || custom_cabinets.to_s == "true"
      @move_plumbing = move_plumbing == true || move_plumbing.to_s == "true"
      @move_electrical = move_electrical == true || move_electrical.to_s == "true"
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tier = TIERS[@tier]
      base = @size_sqft * tier[:per_sqft]
      base *= CUSTOM_CABINET_MULTIPLIER if @custom_cabinets
      add_ons = 0.0
      add_ons += MOVE_PLUMBING_COST if @move_plumbing
      add_ons += MOVE_ELECTRICAL_COST if @move_electrical
      total = base + add_ons
      breakdown = BREAKDOWN.transform_values { |pct| (base * pct).round(0) }

      {
        valid: true,
        tier_label: tier[:label],
        per_sqft_rate: (base / @size_sqft).round(0),
        base_cost: base.round(0),
        add_on_cost: add_ons.round(0),
        total_cost: total.round(0),
        low_estimate: (total * 0.85).round(0),
        high_estimate: (total * 1.15).round(0),
        breakdown: breakdown
      }
    end

    private

    def validate!
      @errors << "Size must be greater than zero" unless @size_sqft.positive?
      @errors << "Tier must be one of: #{TIERS.keys.join(', ')}" unless TIERS.key?(@tier)
    end
  end
end
