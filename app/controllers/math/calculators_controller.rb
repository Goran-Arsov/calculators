module Math
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def percentage; end
    def fraction; end
    def area; end
    def circumference; end
    def exponent; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
