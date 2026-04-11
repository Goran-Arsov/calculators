require "test_helper"

module Construction
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get paint" do
      get construction_paint_url
      assert_response :success
      assert_select "h1", /Paint Calculator/
    end

    test "should get flooring" do
      get construction_flooring_url
      assert_response :success
      assert_select "h1", /Flooring Calculator/
    end

    test "should get concrete" do
      get construction_concrete_url
      assert_response :success
      assert_select "h1", /Concrete Calculator/
    end

    test "should get gravel_mulch" do
      get construction_gravel_mulch_url
      assert_response :success
      assert_select "h1", /Gravel/
    end

    test "should get fence" do
      get construction_fence_url
      assert_response :success
      assert_select "h1", /Fence Calculator/
    end

    HOME_IMPROVEMENT_PATHS = [
      [ :construction_grout_url, /Grout Calculator/ ],
      [ :construction_carpet_url, /Carpet Calculator/ ],
      [ :construction_baseboard_url, /Baseboard Calculator/ ],
      [ :construction_siding_url, /Siding Calculator/ ],
      [ :construction_gutter_url, /Gutter Calculator/ ],
      [ :construction_water_heater_sizing_url, /Water Heater Sizing Calculator/ ],
      [ :construction_pool_volume_url, /Pool Volume Calculator/ ],
      [ :construction_kitchen_remodel_url, /Kitchen Remodel Cost Calculator/ ],
      [ :construction_bathroom_remodel_url, /Bathroom Remodel Cost Calculator/ ],
      [ :construction_attic_ventilation_url, /Attic Ventilation Calculator/ ]
    ].freeze

    HOME_IMPROVEMENT_PATHS.each do |helper, heading|
      test "GET #{helper} renders successfully" do
        get send(helper)
        assert_response :success
        assert_select "h1", heading
      end
    end
  end
end
