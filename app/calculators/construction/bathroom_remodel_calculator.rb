# frozen_string_literal: true

module Construction
  class BathroomRemodelCalculator
    attr_reader :errors

    TIERS = {
      "minor" => { label: "Minor (cosmetic refresh)", per_sqft: 125.0 },
      "midrange" => { label: "Midrange (new fixtures + tile)", per_sqft: 275.0 },
      "major" => { label: "Major (full gut remodel)", per_sqft: 425.0 },
      "luxury" => { label: "Luxury (high-end finishes, custom)", per_sqft: 650.0 }
    }.freeze

    MOVE_PLUMBING_COST = 1500.0
    ADD_SHOWER_COST = 3000.0
    WALK_IN_TUB_COST = 5000.0

    BREAKDOWN = {
      fixtures: 0.20,
      cabinetry: 0.15,
      tile_and_flooring: 0.20,
      labor: 0.25,
      plumbing: 0.10,
      lighting_electrical: 0.05,
      other: 0.05
    }.freeze

    def initialize(size_sqft:, tier:, move_plumbing: false, add_shower: false, walk_in_tub: false)
      @size_sqft = size_sqft.to_f
      @tier = tier.to_s
      @move_plumbing = truthy?(move_plumbing)
      @add_shower = truthy?(add_shower)
      @walk_in_tub = truthy?(walk_in_tub)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tier = TIERS[@tier]
      base = @size_sqft * tier[:per_sqft]
      add_ons = 0.0
      add_ons += MOVE_PLUMBING_COST if @move_plumbing
      add_ons += ADD_SHOWER_COST if @add_shower
      add_ons += WALK_IN_TUB_COST if @walk_in_tub
      total = base + add_ons
      breakdown = BREAKDOWN.transform_values { |pct| (base * pct).round(0) }

      {
        valid: true,
        tier_label: tier[:label],
        per_sqft_rate: tier[:per_sqft],
        base_cost: base.round(0),
        add_on_cost: add_ons.round(0),
        total_cost: total.round(0),
        low_estimate: (total * 0.85).round(0),
        high_estimate: (total * 1.15).round(0),
        breakdown: breakdown
      }
    end

    private

    def truthy?(val)
      val == true || val.to_s == "true"
    end

    def validate!
      @errors << "Size must be greater than zero" unless @size_sqft.positive?
      @errors << "Tier must be one of: #{TIERS.keys.join(', ')}" unless TIERS.key?(@tier)
    end
  end
end
