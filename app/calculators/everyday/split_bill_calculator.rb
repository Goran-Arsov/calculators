# frozen_string_literal: true

module Everyday
  class SplitBillCalculator
    attr_reader :errors

    def initialize(subtotal:, tip_percent:, tax_percent:, num_people:)
      @subtotal = subtotal.to_f
      @tip_percent = tip_percent.to_f
      @tax_percent = tax_percent.to_f
      @num_people = num_people.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tip_amount = @subtotal * (@tip_percent / 100.0)
      tax_amount = @subtotal * (@tax_percent / 100.0)
      total = @subtotal + tip_amount + tax_amount
      per_person = total / @num_people.to_f

      {
        valid: true,
        tip_amount: tip_amount.round(2),
        tax_amount: tax_amount.round(2),
        total: total.round(2),
        per_person: per_person.round(2)
      }
    end

    private

    def validate!
      @errors << "Subtotal must be greater than zero" unless @subtotal.positive?
      @errors << "Tip percent cannot be negative" if @tip_percent.negative?
      @errors << "Tax percent cannot be negative" if @tax_percent.negative?
      @errors << "Number of people must be at least 1" unless @num_people >= 1
    end
  end
end
