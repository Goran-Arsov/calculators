# frozen_string_literal: true

module Relationships
  class EngagementRingCalculator
    attr_reader :errors

    RULE_MONTHS = { "one" => 1, "two" => 2, "three" => 3 }.freeze

    def initialize(annual_salary:, rule: "two")
      @annual_salary = annual_salary.to_f
      @rule = rule.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly = @annual_salary / 12.0
      months = RULE_MONTHS[@rule]
      target = monthly * months
      low = target * 0.7
      high = target * 1.3

      {
        valid: true,
        annual_salary: @annual_salary,
        monthly_salary: monthly.round(2),
        rule: @rule,
        months: months,
        target: target.round(2),
        low: low.round(2),
        high: high.round(2),
        percent_of_salary: ((target / @annual_salary) * 100).round(1)
      }
    end

    private

    def validate!
      @errors << "Annual salary must be greater than zero" unless @annual_salary.positive?
      @errors << "Rule must be one, two, or three months" unless RULE_MONTHS.key?(@rule)
    end
  end
end
