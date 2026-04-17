require "test_helper"

module Automotive
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    {
      mpg: :automotive_mpg_url,
      car_depreciation: :automotive_car_depreciation_url,
      tire_size_comparison: :automotive_tire_size_comparison_url,
      zero_to_sixty: :automotive_zero_to_sixty_url,
      engine_horsepower: :automotive_engine_horsepower_url,
      oil_change_interval: :automotive_oil_change_interval_url,
      car_payment_total_cost: :automotive_car_payment_total_cost_url,
      towing_capacity: :automotive_towing_capacity_url,
      ev_range: :automotive_ev_range_url,
      ev_charging_cost: :automotive_ev_charging_cost_url,
      ev_vs_gas_comparison: :automotive_ev_vs_gas_comparison_url
    }.each do |action, url_helper|
      test "should get #{action}" do
        get send(url_helper)
        assert_response :success
        assert_select "h1"
      end
    end
  end
end
