require "test_helper"

module Everyday
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get tip" do
      get everyday_tip_url
      assert_response :success
      assert_select "h1", /Tip Calculator/
    end

    test "should get discount" do
      get everyday_discount_url
      assert_response :success
      assert_select "h1", /Discount Calculator/
    end

    test "should get age" do
      get everyday_age_url
      assert_response :success
      assert_select "h1", /Age Calculator/
    end

    test "should get date_difference" do
      get everyday_date_difference_url
      assert_response :success
      assert_select "h1", /Date Difference/
    end

    test "should get gas_mileage" do
      get everyday_gas_mileage_url
      assert_response :success
      assert_select "h1", /Gas Mileage/
    end

    test "should get fuel_cost" do
      get everyday_fuel_cost_url
      assert_response :success
      assert_select "h1", /Fuel Cost/
    end

    test "should get gpa" do
      get everyday_gpa_url
      assert_response :success
      assert_select "h1", /GPA Calculator/
    end

    test "should get cooking_converter" do
      get everyday_cooking_converter_url
      assert_response :success
      assert_select "h1", /Cooking/
    end
  end
end
