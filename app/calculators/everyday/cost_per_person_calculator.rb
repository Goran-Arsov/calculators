# frozen_string_literal: true

module Everyday
  class CostPerPersonCalculator
    attr_reader :errors

    def initialize(total_cost:, people:, tip_percent: 0, tax_percent: 0)
      @total_cost = total_cost.to_f
      @people = people.to_i
      @tip_percent = tip_percent.to_f
      @tax_percent = tax_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      tax_amount = @total_cost * (@tax_percent / 100.0)
      tip_amount = @total_cost * (@tip_percent / 100.0)
      grand_total = @total_cost + tax_amount + tip_amount
      cost_per_person = grand_total / @people
      tip_per_person = tip_amount / @people
      tax_per_person = tax_amount / @people

      {
        cost_per_person: cost_per_person.round(2),
        grand_total: grand_total.round(2),
        tax_amount: tax_amount.round(2),
        tip_amount: tip_amount.round(2),
        tip_per_person: tip_per_person.round(2),
        tax_per_person: tax_per_person.round(2),
        base_per_person: (@total_cost / @people).round(2)
      }
    end

    private

    def validate!
      @errors << "Total cost must be greater than zero" unless @total_cost.positive?
      @errors << "Number of people must be at least 1" unless @people >= 1
      @errors << "Tip percent cannot be negative" if @tip_percent.negative?
      @errors << "Tax percent cannot be negative" if @tax_percent.negative?
    end
  end
end
