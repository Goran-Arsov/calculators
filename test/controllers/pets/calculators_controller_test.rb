require "test_helper"

module Pets
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      cat_age: :pets_cat_age_url,
      cat_food: :pets_cat_food_url,
      fish_tank: :pets_fish_tank_url,
      pet_insurance_roi: :pets_pet_insurance_roi_url,
      pet_medication_dosage: :pets_pet_medication_dosage_url,
      puppy_weight_predictor: :pets_puppy_weight_predictor_url,
      horse_feed: :pets_horse_feed_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
