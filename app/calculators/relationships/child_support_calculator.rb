# frozen_string_literal: true

module Relationships
  class ChildSupportCalculator
    attr_reader :errors

    # Approximation of the income shares model (used by ~40 US states)
    BASIC_OBLIGATION_PERCENT = {
      1 => 0.17,
      2 => 0.25,
      3 => 0.29,
      4 => 0.31,
      5 => 0.33
    }.freeze

    def initialize(payor_income:, other_parent_income:, num_children:)
      @payor_income = payor_income.to_f
      @other_parent_income = other_parent_income.to_f
      @num_children = num_children.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_income = @payor_income + @other_parent_income
      percent = BASIC_OBLIGATION_PERCENT[[ @num_children, 5 ].min]
      total_obligation = total_income * percent
      payor_share_ratio = @payor_income / total_income
      payor_monthly = (total_obligation * payor_share_ratio) / 12.0

      {
        valid: true,
        monthly_amount: payor_monthly.round(2),
        annual_amount: (payor_monthly * 12).round(2),
        total_obligation: total_obligation.round(2),
        payor_share_percent: (payor_share_ratio * 100).round(1),
        num_children: @num_children
      }
    end

    private

    def validate!
      @errors << "Payor income must be greater than zero" unless @payor_income.positive?
      @errors << "Other parent income cannot be negative" if @other_parent_income.negative?
      @errors << "Number of children must be at least 1" if @num_children < 1
    end
  end
end
