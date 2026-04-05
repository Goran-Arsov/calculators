module Finance
  class CryptoProfitCalculator
    attr_reader :errors

    SHORT_TERM_RATE = 0.24
    LONG_TERM_RATE = 0.15

    def initialize(buy_price:, sell_price:, quantity:, buy_fee_percent: 0, sell_fee_percent: 0, holding_period: "long")
      @buy_price = buy_price.to_f
      @sell_price = sell_price.to_f
      @quantity = quantity.to_f
      @buy_fee_percent = buy_fee_percent.to_f / 100.0
      @sell_fee_percent = sell_fee_percent.to_f / 100.0
      @holding_period = holding_period.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      cost_basis = @buy_price * @quantity
      buy_fee = cost_basis * @buy_fee_percent
      total_cost = cost_basis + buy_fee

      gross_revenue = @sell_price * @quantity
      sell_fee = gross_revenue * @sell_fee_percent
      net_revenue = gross_revenue - sell_fee

      total_fees = buy_fee + sell_fee
      profit = net_revenue - total_cost
      roi = total_cost > 0 ? (profit / total_cost * 100) : 0.0
      percent_change = @buy_price > 0 ? ((@sell_price - @buy_price) / @buy_price * 100) : 0.0

      tax_rate = @holding_period == "short" ? SHORT_TERM_RATE : LONG_TERM_RATE
      capital_gains_tax = profit > 0 ? profit * tax_rate : 0.0
      after_tax_profit = profit - capital_gains_tax

      break_even_price = @quantity > 0 ? (total_cost + total_cost * @sell_fee_percent) / @quantity : 0.0

      {
        valid: true,
        cost_basis: cost_basis.round(2),
        total_cost: total_cost.round(2),
        gross_revenue: gross_revenue.round(2),
        net_revenue: net_revenue.round(2),
        profit: profit.round(2),
        roi: roi.round(2),
        percent_change: percent_change.round(2),
        total_fees: total_fees.round(2),
        capital_gains_tax: capital_gains_tax.round(2),
        after_tax_profit: after_tax_profit.round(2),
        break_even_price: break_even_price.round(2),
        holding_period: @holding_period
      }
    end

    private

    def validate!
      @errors << "Buy price must be positive" unless @buy_price > 0
      @errors << "Sell price must be positive" unless @sell_price > 0
      @errors << "Quantity must be positive" unless @quantity > 0
      @errors << "Buy fee percent cannot be negative" if @buy_fee_percent < 0
      @errors << "Sell fee percent cannot be negative" if @sell_fee_percent < 0
      @errors << "Holding period must be 'short' or 'long'" unless %w[short long].include?(@holding_period)
    end
  end
end
