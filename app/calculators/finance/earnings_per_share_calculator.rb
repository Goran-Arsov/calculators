# frozen_string_literal: true

module Finance
  class EarningsPerShareCalculator
    attr_reader :errors

    def initialize(net_income:, preferred_dividends:, shares_outstanding:, stock_price: nil)
      @net_income = net_income.to_f
      @preferred_dividends = preferred_dividends.to_f
      @shares_outstanding = shares_outstanding.to_i
      @stock_price = stock_price.nil? || stock_price.to_s.strip.empty? ? nil : stock_price.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      basic_eps = (@net_income - @preferred_dividends) / @shares_outstanding

      result = {
        valid: true,
        basic_eps: basic_eps.round(4),
        net_income: @net_income.round(2),
        preferred_dividends: @preferred_dividends.round(2),
        shares_outstanding: @shares_outstanding,
        earnings_available: (@net_income - @preferred_dividends).round(2)
      }

      if @stock_price && @stock_price > 0 && basic_eps > 0
        pe_ratio = @stock_price / basic_eps
        earnings_yield = (basic_eps / @stock_price) * 100.0
        result[:stock_price] = @stock_price.round(2)
        result[:pe_ratio] = pe_ratio.round(4)
        result[:earnings_yield] = earnings_yield.round(4)
      end

      result
    end

    private

    def validate!
      @errors << "Shares outstanding must be positive" unless @shares_outstanding > 0
      @errors << "Preferred dividends cannot be negative" if @preferred_dividends < 0
      @errors << "Preferred dividends cannot exceed net income" if @net_income > 0 && @preferred_dividends > @net_income
      @errors << "Stock price must be positive" if @stock_price && @stock_price <= 0
    end
  end
end
