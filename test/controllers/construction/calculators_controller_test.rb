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
  end
end
