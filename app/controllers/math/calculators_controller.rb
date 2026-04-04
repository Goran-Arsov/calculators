module Math
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def percentage; end
    def fraction; end
    def area; end
    def circumference; end
    def exponent; end
    def pythagorean; end
    def quadratic; end
    def standard_deviation; end
    def gcd_lcm; end
    def sample_size; end
    def aspect_ratio; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
