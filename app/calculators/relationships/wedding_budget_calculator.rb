# frozen_string_literal: true

module Relationships
  class WeddingBudgetCalculator
    attr_reader :errors

    # Typical wedding budget breakdown from The Knot 2024 averages
    ALLOCATION = {
      venue: 0.37,
      catering: 0.22,
      photography: 0.10,
      attire: 0.05,
      flowers: 0.08,
      music: 0.06,
      rings: 0.03,
      invitations: 0.02,
      transport: 0.02,
      favors_misc: 0.05
    }.freeze

    def initialize(total_budget:, guest_count: 100)
      @total_budget = total_budget.to_f
      @guest_count = guest_count.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      breakdown = ALLOCATION.transform_values { |pct| (@total_budget * pct).round(2) }
      cost_per_guest = (@total_budget / @guest_count).round(2)

      {
        valid: true,
        total_budget: @total_budget,
        guest_count: @guest_count,
        cost_per_guest: cost_per_guest,
        breakdown: breakdown
      }
    end

    private

    def validate!
      @errors << "Total budget must be greater than zero" unless @total_budget.positive?
      @errors << "Guest count must be at least 1" if @guest_count < 1
    end
  end
end
