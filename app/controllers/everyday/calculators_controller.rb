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
    def time_zone_converter; end
    def shoe_size; end
    def grade; end
    def electricity_bill; end
    def moving_cost; end
    def password_strength; end
    def screen_size; end
    def bandwidth; end
    def unit_price; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
