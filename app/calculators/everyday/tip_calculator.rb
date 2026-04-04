# frozen_string_literal: true

module Everyday
  class TipCalculator
    attr_reader :errors

    def initialize(bill_amount:, tip_percent:, split: 1)
      @bill_amount = bill_amount.to_f
      @tip_percent = tip_percent.to_f
      @split = split.to_i
      @errors = []
    end

    def call
      validate!
      return { errors: @errors } if @errors.any?

      tip_amount = @bill_amount * (@tip_percent / 100.0)
      total = @bill_amount + tip_amount
      per_person = total / @split.to_f

      {
        tip_amount: tip_amount.round(2),
        total: total.round(2),
        per_person: per_person.round(2)
      }
    end

    private

    def validate!
      @errors << "Bill amount must be greater than zero" unless @bill_amount.positive?
      @errors << "Tip percent cannot be negative" if @tip_percent.negative?
      @errors << "Split must be at least 1" unless @split >= 1
    end
  end
end
