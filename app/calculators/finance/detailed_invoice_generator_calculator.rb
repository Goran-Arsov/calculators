# frozen_string_literal: true

module Finance
  class DetailedInvoiceGeneratorCalculator
    attr_reader :errors

    VALID_DISCOUNT_TYPES = %w[percent flat none].freeze

    def initialize(line_items:)
      @line_items = line_items || []
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      computed_items = @line_items.map do |item|
        qty = item[:quantity].to_f
        unit_price = item[:unit_price].to_f
        tax = item[:tax].to_f
        discount_type = item[:discount_type].to_s

        subtotal = qty * unit_price
        tax_amount = subtotal * tax / 100.0
        price_with_tax = subtotal + tax_amount

        discount_amount = case discount_type
        when "percent"
          price_with_tax * item[:discount_value].to_f / 100.0
        when "flat"
          item[:discount_value].to_f
        else
          0.0
        end

        line_total = price_with_tax - discount_amount

        {
          item_name: item[:item_name].to_s,
          item_code: item[:item_code].to_s,
          unit: item[:unit].to_s,
          unit_price: unit_price.round(2),
          quantity: qty,
          tax: tax,
          tax_amount: tax_amount.round(2),
          subtotal: subtotal.round(2),
          price_with_tax: price_with_tax.round(2),
          discount_type: discount_type,
          discount_value: item[:discount_value].to_f.round(2),
          discount_amount: discount_amount.round(2),
          line_total: line_total.round(2)
        }
      end

      total_subtotal = computed_items.sum { |i| i[:subtotal] }
      total_tax = computed_items.sum { |i| i[:tax_amount] }
      total_discount = computed_items.sum { |i| i[:discount_amount] }
      grand_total = computed_items.sum { |i| i[:line_total] }

      {
        valid: true,
        line_items: computed_items,
        subtotal: total_subtotal.round(2),
        total_tax: total_tax.round(2),
        total_discount: total_discount.round(2),
        grand_total: grand_total.round(2)
      }
    end

    private

    def validate!
      @errors << "At least one line item is required" if @line_items.empty?

      @line_items.each_with_index do |item, index|
        pos = index + 1
        qty = item[:quantity].to_f
        price = item[:unit_price].to_f
        tax = item[:tax].to_f

        @errors << "Line item #{pos}: quantity must be greater than 0" unless qty > 0
        @errors << "Line item #{pos}: unit price must be 0 or greater" if price < 0
        @errors << "Line item #{pos}: tax must be between 0 and 100" unless tax >= 0 && tax <= 100

        discount_type = item[:discount_type].to_s
        if discount_type.present? && !VALID_DISCOUNT_TYPES.include?(discount_type)
          @errors << "Line item #{pos}: discount type must be percent, flat, or none"
        end

        discount_value = item[:discount_value].to_f
        @errors << "Line item #{pos}: discount value must be 0 or greater" if discount_value < 0
      end
    end
  end
end
