require "test_helper"

module Math
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get percentage" do
      get math_percentage_url
      assert_response :success
      assert_select "h1", /Percentage Calculator/
    end

    test "should get fraction" do
      get math_fraction_url
      assert_response :success
      assert_select "h1", /Fraction Calculator/
    end

    test "should get area" do
      get math_area_url
      assert_response :success
      assert_select "h1", /Area Calculator/
    end

    test "should get circumference" do
      get math_circumference_url
      assert_response :success
      assert_select "h1", /Circumference Calculator/
    end

    test "should get exponent" do
      get math_exponent_url
      assert_response :success
      assert_select "h1", /Exponent Calculator/
    end
  end
end
