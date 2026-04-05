module Construction
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def paint; end
    def flooring; end
    def concrete; end
    def gravel_mulch; end
    def fence; end
    def roofing; end
    def staircase; end
    def deck; end
    def wallpaper; end
    def tile; end
    def lumber; end
    def hvac_btu; end
    def sqft_cost; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
