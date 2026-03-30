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

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
