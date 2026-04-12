# frozen_string_literal: true

module Relationships
  class ChildCostCalculator
    attr_reader :errors

    # USDA "Expenditures on Children by Families" 2015 baseline adjusted ~30% for inflation to 2026
    BASE_COST_TO_18 = {
      "low" => 215000,
      "middle" => 310000,
      "high" => 455000
    }.freeze

    # Cost-of-living multipliers
    COL_MULTIPLIER = {
      "lcol" => 0.82,
      "mcol" => 1.0,
      "hcol" => 1.28
    }.freeze

    # USDA category percentages
    CATEGORIES = {
      housing: 0.29,
      food: 0.18,
      childcare_education: 0.16,
      transportation: 0.15,
      healthcare: 0.09,
      clothing: 0.06,
      miscellaneous: 0.07
    }.freeze

    # Additional kids get multi-child discount
    DISCOUNT_PER_EXTRA_CHILD = 0.24

    def initialize(income_tier:, col:, num_children: 1)
      @income_tier = income_tier.to_s
      @col = col.to_s
      @num_children = num_children.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      base = BASE_COST_TO_18[@income_tier] * COL_MULTIPLIER[@col]
      per_child_adjusted = base
      total = base
      (@num_children - 1).times { total += base * (1 - DISCOUNT_PER_EXTRA_CHILD) }

      annual_per_child = per_child_adjusted / 18.0
      monthly_per_child = annual_per_child / 12.0

      breakdown = CATEGORIES.transform_values { |pct| (per_child_adjusted * pct).round(2) }

      {
        valid: true,
        total_cost: total.round(2),
        per_child: per_child_adjusted.round(2),
        annual_per_child: annual_per_child.round(2),
        monthly_per_child: monthly_per_child.round(2),
        breakdown: breakdown
      }
    end

    private

    def validate!
      @errors << "Income tier is invalid" unless BASE_COST_TO_18.key?(@income_tier)
      @errors << "Cost of living is invalid" unless COL_MULTIPLIER.key?(@col)
      @errors << "Number of children must be at least 1" if @num_children < 1
    end
  end
end
