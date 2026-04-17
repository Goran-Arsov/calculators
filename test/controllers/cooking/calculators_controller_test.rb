require "test_helper"

module Cooking
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      recipe_scaler: :cooking_recipe_scaler_url,
      baking_substitution: :cooking_baking_substitution_url,
      sourdough_hydration: :cooking_sourdough_hydration_url,
      meat_cooking_time: :cooking_meat_cooking_time_url,
      smoke_time: :cooking_smoke_time_url,
      pizza_dough: :cooking_pizza_dough_url,
      canning_altitude: :cooking_canning_altitude_url,
      freezer_storage: :cooking_freezer_storage_url,
      meal_prep_cost: :cooking_meal_prep_cost_url,
      macros_per_recipe: :cooking_macros_per_recipe_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
