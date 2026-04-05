require "test_helper"

class SuitesControllerTest < ActionDispatch::IntegrationTest
  test "should get home_buying suite" do
    get suite_home_buying_url
    assert_response :success
    assert_select "h1", /Home Buying Calculator Suite/
  end

  test "should get fitness suite" do
    get suite_fitness_url
    assert_response :success
    assert_select "h1", /Fitness Calculator Suite/
  end

  test "should get business_startup suite" do
    get suite_business_startup_url
    assert_response :success
    assert_select "h1", /Business Startup Calculator Suite/
  end

  test "home_buying sets cache headers" do
    get suite_home_buying_url
    assert_response :success
    assert_match(/max-age=21600/, response.headers["Cache-Control"])
    assert_match(/public/, response.headers["Cache-Control"])
  end

  test "fitness sets cache headers" do
    get suite_fitness_url
    assert_response :success
    assert_match(/max-age=21600/, response.headers["Cache-Control"])
    assert_match(/public/, response.headers["Cache-Control"])
  end

  test "business_startup sets cache headers" do
    get suite_business_startup_url
    assert_response :success
    assert_match(/max-age=21600/, response.headers["Cache-Control"])
    assert_match(/public/, response.headers["Cache-Control"])
  end

  test "home_buying has suite-stepper controller" do
    get suite_home_buying_url
    assert_response :success
    assert_select "[data-controller='suite-stepper']", 1
  end

  test "fitness has suite-stepper controller" do
    get suite_fitness_url
    assert_response :success
    assert_select "[data-controller='suite-stepper']", 1
  end

  test "business_startup has suite-stepper controller" do
    get suite_business_startup_url
    assert_response :success
    assert_select "[data-controller='suite-stepper']", 1
  end

  test "home_buying has breadcrumb schema" do
    get suite_home_buying_url
    assert_response :success
    assert_select "script[type='application/ld+json']", minimum: 1
  end

  test "home_buying links to related calculators" do
    get suite_home_buying_url
    assert_response :success
    assert_select "a[href='#{finance_home_affordability_path}']", minimum: 1
    assert_select "a[href='#{finance_mortgage_path}']", minimum: 1
    assert_select "a[href='#{finance_rent_vs_buy_path}']", minimum: 1
  end

  test "fitness links to related calculators" do
    get suite_fitness_url
    assert_response :success
    assert_select "a[href='#{health_bmi_path}']", minimum: 1
    assert_select "a[href='#{health_tdee_path}']", minimum: 1
    assert_select "a[href='#{health_macro_path}']", minimum: 1
    assert_select "a[href='#{health_calorie_deficit_path}']", minimum: 1
  end

  test "business_startup links to related calculators" do
    get suite_business_startup_url
    assert_response :success
    assert_select "a[href='#{finance_break_even_path}']", minimum: 1
    assert_select "a[href='#{finance_business_loan_path}']", minimum: 1
    assert_select "a[href='#{finance_roi_path}']", minimum: 1
  end
end
