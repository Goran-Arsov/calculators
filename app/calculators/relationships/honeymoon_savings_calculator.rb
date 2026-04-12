# frozen_string_literal: true

module Relationships
  class HoneymoonSavingsCalculator
    attr_reader :errors

    def initialize(target_cost:, current_savings:, months_available:)
      @target_cost = target_cost.to_f
      @current_savings = current_savings.to_f
      @months_available = months_available.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gap = [ @target_cost - @current_savings, 0 ].max
      monthly_needed = @months_available.positive? ? (gap / @months_available) : gap
      weekly_needed = monthly_needed / 4.33
      daily_needed = monthly_needed / 30.0
      on_track = @current_savings >= @target_cost

      {
        valid: true,
        target_cost: @target_cost,
        current_savings: @current_savings,
        gap: gap.round(2),
        monthly_needed: monthly_needed.round(2),
        weekly_needed: weekly_needed.round(2),
        daily_needed: daily_needed.round(2),
        on_track: on_track
      }
    end

    private

    def validate!
      @errors << "Target cost must be greater than zero" unless @target_cost.positive?
      @errors << "Current savings cannot be negative" if @current_savings.negative?
      @errors << "Months available must be greater than zero" unless @months_available.positive?
    end
  end
end
