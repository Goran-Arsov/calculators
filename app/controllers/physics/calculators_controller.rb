module Physics
  class CalculatorsController < ApplicationController
    before_action :set_cache_headers

    def velocity; end
    def force; end
    def kinetic_energy; end
    def ohms_law; end
    def projectile_motion; end
    def element_mass; end
    def element_volume; end
    def unit_converter; end
    def electricity_cost; end
    def wire_gauge; end
    def decibel; end
    def wavelength_frequency; end

    private

    def set_cache_headers
      expires_in 1.hour, public: true
    end
  end
end
