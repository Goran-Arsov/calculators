# frozen_string_literal: true

module Finance
  class VatCalculator
    attr_reader :errors

    # mode: "add" (net to gross) or "remove" (gross to net)
    def initialize(amount:, vat_rate:, mode: "add")
      @amount = amount.to_f
      @vat_rate = vat_rate.to_f / 100.0
      @mode = mode.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @mode == "add"
        net_price = @amount
        vat_amount = net_price * @vat_rate
        gross_price = net_price + vat_amount
      else
        gross_price = @amount
        net_price = gross_price / (1 + @vat_rate)
        vat_amount = gross_price - net_price
      end

      {
        valid: true,
        net_price: net_price.round(2),
        vat_amount: vat_amount.round(2),
        gross_price: gross_price.round(2),
        vat_rate: (@vat_rate * 100.0).round(4),
        mode: @mode
      }
    end

    private

    def validate!
      @errors << "Amount must be positive" unless @amount > 0
      @errors << "VAT rate cannot be negative" if @vat_rate < 0
      @errors << "Mode must be 'add' or 'remove'" unless %w[add remove].include?(@mode)
    end
  end
end
