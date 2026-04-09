# frozen_string_literal: true

module Everyday
  class WeddingBudgetCalculator
    attr_reader :errors

    BREAKDOWN = {
      venue: 0.30,
      catering: 0.25,
      photography: 0.12,
      flowers: 0.08,
      music: 0.07,
      attire: 0.06,
      stationery: 0.03,
      other: 0.09
    }.freeze

    def initialize(total_budget:, guest_count:)
      @total_budget = total_budget.to_f
      @guest_count = guest_count.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      per_guest_cost = @total_budget / @guest_count.to_f

      {
        valid: true,
        per_guest_cost: per_guest_cost.round(2),
        venue_budget: (@total_budget * BREAKDOWN[:venue]).round(2),
        catering_budget: (@total_budget * BREAKDOWN[:catering]).round(2),
        photography_budget: (@total_budget * BREAKDOWN[:photography]).round(2),
        flowers_budget: (@total_budget * BREAKDOWN[:flowers]).round(2),
        music_budget: (@total_budget * BREAKDOWN[:music]).round(2),
        attire_budget: (@total_budget * BREAKDOWN[:attire]).round(2),
        stationery_budget: (@total_budget * BREAKDOWN[:stationery]).round(2),
        other_budget: (@total_budget * BREAKDOWN[:other]).round(2)
      }
    end

    private

    def validate!
      @errors << "Total budget must be greater than zero" unless @total_budget.positive?
      @errors << "Guest count must be at least 1" unless @guest_count >= 1
    end
  end
end
