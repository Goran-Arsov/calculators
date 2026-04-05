module Finance
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def mortgage; end
    def compound_interest; end
    def loan; end
    def investment; end
    def retirement; end
    def debt_payoff; end
    def salary; end
    def savings_goal; end
    def roi; end
    def profit_margin; end
    def inflation; end
    def break_even; end
    def markup_margin; end
    def rent_vs_buy; end
    def dividend_yield; end
    def dca; end
    def solar_savings; end
    def tax_bracket; end
    def auto_loan; end
    def credit_card_payoff; end
    def net_worth; end
    def home_affordability; end
    def business_loan; end
    def currency_converter; end
    def paycheck; end
    def four_oh_one_k; end
    def amortization; end
    def stock_profit; end
    def cd; end
    def savings_interest; end
    def house_flip; end
    def student_loan; end
    def estate_tax; end
    def crypto_profit; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
