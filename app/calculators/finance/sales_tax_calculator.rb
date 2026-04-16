# frozen_string_literal: true

module Finance
  class SalesTaxCalculator
    attr_reader :errors

    def initialize(subtotal:, tax_rate:)
      @subtotal = subtotal.to_f
      @tax_rate = tax_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      tax_amount = @subtotal * @tax_rate
      total = @subtotal + tax_amount

      {
        valid: true,
        subtotal: @subtotal.round(2),
        tax_rate: (@tax_rate * 100.0).round(4),
        tax_amount: tax_amount.round(2),
        total: total.round(2)
      }
    end

    private

    def validate!
      @errors << "Subtotal must be positive" unless @subtotal > 0
      @errors << "Tax rate cannot be negative" if @tax_rate < 0
    end
  end
end
