module Everyday
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def tip; end
    def discount; end
    def age; end
    def date_difference; end
    def gas_mileage; end
    def fuel_cost; end
    def gpa; end
    def cooking_converter; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
