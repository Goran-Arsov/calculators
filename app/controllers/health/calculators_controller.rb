module Health
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def bmi; end
    def calorie; end
    def body_fat; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
