# frozen_string_literal: true

module Everyday
  class DiscountCalculator
    attr_reader :errors

    def initialize(original_price:, discount_percent:)
      @original_price = original_price.to_f
      @discount_percent = discount_percent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      discount_amount = @original_price * (@discount_percent / 100.0)
      sale_price = @original_price - discount_amount
      savings = discount_amount

      {
        valid: true,
        sale_price: sale_price.round(2),
        savings: savings.round(2),
        discount_amount: discount_amount.round(2)
      }
    end

    private

    def validate!
      @errors << "Original price must be greater than zero" unless @original_price.positive?
      @errors << "Discount percent must be between 0 and 100" unless @discount_percent.between?(0, 100)
    end
  end
end
