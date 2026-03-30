require "test_helper"

module Health
  class CalculatorsControllerTest < ActionDispatch::IntegrationTest
    test "should get bmi" do
      get health_bmi_url
      assert_response :success
      assert_select "h1", /BMI Calculator/
    end

    test "should get calorie" do
      get health_calorie_url
      assert_response :success
      assert_select "h1", /Calorie Calculator/
    end

    test "should get body fat" do
      get health_body_fat_url
      assert_response :success
      assert_select "h1", /Body Fat/i
    end
  end
end
