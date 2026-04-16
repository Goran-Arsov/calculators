# frozen_string_literal: true

module Finance
  class StockProfitCalculator
    attr_reader :errors

    LONG_TERM_CAPITAL_GAINS_RATE = 0.15
    SHORT_TERM_CAPITAL_GAINS_RATE = 0.24

    def initialize(buy_price:, sell_price:, shares:, buy_commission: 0, sell_commission: 0, holding_period: "long")
      @buy_price = buy_price.to_f
      @sell_price = sell_price.to_f
      @shares = shares.to_f
      @buy_commission = buy_commission.to_f
      @sell_commission = sell_commission.to_f
      @holding_period = holding_period.to_s.downcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_cost = (@buy_price * @shares) + @buy_commission
      total_revenue = (@sell_price * @shares) - @sell_commission
      total_fees = @buy_commission + @sell_commission
      profit = total_revenue - total_cost

      roi = total_cost > 0 ? (profit / total_cost * 100) : 0.0
      percent_change = @buy_price > 0 ? ((@sell_price - @buy_price) / @buy_price * 100) : 0.0

      capital_gains_rate = @holding_period == "short" ? SHORT_TERM_CAPITAL_GAINS_RATE : LONG_TERM_CAPITAL_GAINS_RATE
      capital_gains_tax = profit > 0 ? profit * capital_gains_rate : 0.0
      after_tax_profit = profit - capital_gains_tax

      break_even_price = @shares > 0 ? (total_cost + @sell_commission) / @shares : 0.0

      {
        valid: true,
        total_cost: total_cost.round(2),
        total_revenue: total_revenue.round(2),
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
      @errors << "Number of shares must be positive" unless @shares > 0
      @errors << "Buy commission cannot be negative" if @buy_commission < 0
      @errors << "Sell commission cannot be negative" if @sell_commission < 0
      @errors << "Holding period must be 'short' or 'long'" unless %w[short long].include?(@holding_period)
    end
  end
end
