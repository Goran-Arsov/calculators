# frozen_string_literal: true

module Finance
  class HouseFlipCalculator
    attr_reader :errors

    def initialize(purchase_price:, renovation_cost:, after_repair_value:, holding_months: 6, holding_cost_monthly: 0, closing_cost_buy_percent: 2, closing_cost_sell_percent: 6)
      @purchase_price = purchase_price.to_f
      @renovation_cost = renovation_cost.to_f
      @arv = after_repair_value.to_f
      @holding_months = holding_months.to_i
      @holding_cost_monthly = holding_cost_monthly.to_f
      @closing_cost_buy_percent = closing_cost_buy_percent.to_f / 100.0
      @closing_cost_sell_percent = closing_cost_sell_percent.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      closing_costs_buy = @purchase_price * @closing_cost_buy_percent
      closing_costs_sell = @arv * @closing_cost_sell_percent
      total_holding_costs = @holding_cost_monthly * @holding_months
      total_investment = @purchase_price + @renovation_cost + closing_costs_buy + total_holding_costs
      total_costs = total_investment + closing_costs_sell

      net_profit = @arv - total_costs
      roi = total_investment > 0 ? (net_profit / total_investment * 100) : 0.0
      annualized_roi = @holding_months > 0 ? roi * (12.0 / @holding_months) : 0.0

      # 70% rule: max purchase = ARV * 70% - renovation cost
      max_purchase_70_rule = @arv * 0.70 - @renovation_cost

      {
        valid: true,
        purchase_price: @purchase_price.round(2),
        renovation_cost: @renovation_cost.round(2),
        after_repair_value: @arv.round(2),
        closing_costs_buy: closing_costs_buy.round(2),
        closing_costs_sell: closing_costs_sell.round(2),
        total_holding_costs: total_holding_costs.round(2),
        total_investment: total_investment.round(2),
        total_costs: total_costs.round(2),
        net_profit: net_profit.round(2),
        roi: roi.round(2),
        annualized_roi: annualized_roi.round(2),
        max_purchase_70_rule: max_purchase_70_rule.round(2),
        holding_months: @holding_months
      }
    end

    private

    def validate!
      @errors << "Purchase price must be positive" unless @purchase_price > 0
      @errors << "Renovation cost cannot be negative" if @renovation_cost < 0
      @errors << "After repair value must be positive" unless @arv > 0
      @errors << "Holding months must be positive" unless @holding_months > 0
      @errors << "Monthly holding cost cannot be negative" if @holding_cost_monthly < 0
      @errors << "Buy closing cost percent cannot be negative" if @closing_cost_buy_percent < 0
      @errors << "Sell closing cost percent cannot be negative" if @closing_cost_sell_percent < 0
    end
  end
end
