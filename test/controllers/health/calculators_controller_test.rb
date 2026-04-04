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

    test "should get pregnancy due date" do
      get health_pregnancy_due_date_url
      assert_response :success
      assert_select "h1", /Pregnancy|Due Date/i
    end

    test "should get tdee" do
      get health_tdee_url
      assert_response :success
      assert_select "h1", /TDEE/
    end

    test "should get macro" do
      get health_macro_url
      assert_response :success
      assert_select "h1", /Macro/
    end

    test "should get pace" do
      get health_pace_url
      assert_response :success
      assert_select "h1", /Pace/
    end

    test "should get water intake" do
      get health_water_intake_url
      assert_response :success
      assert_select "h1", /Water Intake/
    end

    test "should get sleep" do
      get health_sleep_url
      assert_response :success
      assert_select "h1", /Sleep/
    end

    test "should get one rep max" do
      get health_one_rep_max_url
      assert_response :success
      assert_select "h1", /One Rep Max|1RM/i
    end

    test "should get dog age" do
      get health_dog_age_url
      assert_response :success
      assert_select "h1", /Dog Age/
    end

    test "should get pregnancy_week" do
      get health_pregnancy_week_url
      assert_response :success
      assert_select "h1", /Pregnancy Week/
    end

    test "should get dog_food" do
      get health_dog_food_url
      assert_response :success
      assert_select "h1", /Dog Food/
    end
  end
end
