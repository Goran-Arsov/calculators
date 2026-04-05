# frozen_string_literal: true

module Everyday
  class DataUsageCostCalculator
    attr_reader :errors

    def initialize(plan_size_gb:, plan_cost:, actual_usage_gb:, overage_rate_per_gb: 0)
      @plan_size_gb = plan_size_gb.to_f
      @plan_cost = plan_cost.to_f
      @actual_usage_gb = actual_usage_gb.to_f
      @overage_rate_per_gb = overage_rate_per_gb.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_per_gb = @plan_cost / @plan_size_gb

      overage_gb = [ @actual_usage_gb - @plan_size_gb, 0 ].max
      unused_gb = [ @plan_size_gb - @actual_usage_gb, 0 ].max

      overage_cost = overage_gb * @overage_rate_per_gb
      unused_data_value = unused_gb * cost_per_gb

      total_cost = @plan_cost + overage_cost
      effective_cost_per_gb = total_cost / @actual_usage_gb
      usage_percentage = (@actual_usage_gb / @plan_size_gb * 100.0)

      {
        valid: true,
        cost_per_gb: cost_per_gb.round(2),
        overage_gb: overage_gb.round(2),
        overage_cost: overage_cost.round(2),
        unused_gb: unused_gb.round(2),
        unused_data_value: unused_data_value.round(2),
        total_cost: total_cost.round(2),
        effective_cost_per_gb: effective_cost_per_gb.round(2),
        usage_percentage: usage_percentage.round(1)
      }
    end

    private

    def validate!
      @errors << "Plan size must be greater than zero" unless @plan_size_gb.positive?
      @errors << "Plan cost must be greater than zero" unless @plan_cost.positive?
      @errors << "Actual usage must be greater than zero" unless @actual_usage_gb.positive?
      @errors << "Overage rate cannot be negative" if @overage_rate_per_gb.negative?
    end
  end
end
