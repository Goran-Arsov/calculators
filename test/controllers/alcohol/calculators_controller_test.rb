require "test_helper"

module Alcohol
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      abv: :alcohol_abv_url,
      ibu: :alcohol_ibu_url,
      srm: :alcohol_srm_url,
      strike_water: :alcohol_strike_water_url,
      hydrometer_correction: :alcohol_hydrometer_correction_url,
      brix_to_gravity: :alcohol_brix_to_gravity_url,
      yeast_pitch: :alcohol_yeast_pitch_url,
      priming_sugar: :alcohol_priming_sugar_url,
      keg_force_carbonation: :alcohol_keg_force_carbonation_url,
      distiller_proofing: :alcohol_distiller_proofing_url,
      cocktail_abv: :alcohol_cocktail_abv_url,
      pour_cost: :alcohol_pour_cost_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
