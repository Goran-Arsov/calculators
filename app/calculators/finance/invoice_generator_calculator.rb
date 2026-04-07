# frozen_string_literal: true

module Finance
  class InvoiceGeneratorCalculator
    attr_reader :errors

    def initialize(line_items:, tax_rate: 0, discount: 0, discount_type: "percent")
      @line_items = line_items || []
      @tax_rate = tax_rate.to_f
      @discount = discount.to_f
      @discount_type = discount_type.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      subtotal = @line_items.sum { |item| item[:quantity].to_f * item[:unit_price].to_f }

      tax_amount = subtotal * @tax_rate / 100.0

      discount_amount = if @discount_type == "flat"
        @discount
      else
        subtotal * @discount / 100.0
      end

      total = subtotal + tax_amount - discount_amount

      {
        valid: true,
        subtotal: subtotal.round(2),
        tax_amount: tax_amount.round(2),
        discount_amount: discount_amount.round(2),
        total: total.round(2),
        line_items: @line_items.map do |item|
          qty = item[:quantity].to_f
          price = item[:unit_price].to_f
          {
            description: item[:description],
            quantity: qty,
            unit_price: price.round(2),
            amount: (qty * price).round(2)
          }
        end
      }
    end

    private

    def validate!
      @errors << "At least one line item is required" if @line_items.empty?

      @line_items.each_with_index do |item, index|
        qty = item[:quantity].to_f
        price = item[:unit_price].to_f
        @errors << "Line item #{index + 1}: quantity must be greater than 0" unless qty > 0
        @errors << "Line item #{index + 1}: unit price must be 0 or greater" if price < 0
      end

      @errors << "Tax rate must be between 0 and 100" unless @tax_rate >= 0 && @tax_rate <= 100
      @errors << "Discount must be 0 or greater" if @discount < 0
    end
  end
end
