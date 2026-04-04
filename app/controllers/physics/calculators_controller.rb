module Physics
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def velocity; end
    def force; end
    def kinetic_energy; end
    def ohms_law; end
    def projectile_motion; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
