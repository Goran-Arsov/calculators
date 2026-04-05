require "test_helper"

class ComparisonsControllerTest < ActionDispatch::IntegrationTest
  test "should get mortgage_terms comparison" do
    get compare_mortgage_terms_url
    assert_response :success
    assert_select "h1", /15-Year vs 30-Year Mortgage/
  end

  test "should get bmi_vs_body_fat comparison" do
    get compare_bmi_vs_body_fat_url
    assert_response :success
    assert_select "h1", /BMI vs Body Fat/
  end

  test "should get stocks_vs_crypto comparison" do
    get compare_stocks_vs_crypto_url
    assert_response :success
    assert_select "h1", /Stocks vs Crypto/
  end

  test "should get keto_vs_macros comparison" do
    get compare_keto_vs_macros_url
    assert_response :success
    assert_select "h1", /Keto vs Standard Macros/
  end

  test "should get simple_vs_compound comparison" do
    get compare_simple_vs_compound_url
    assert_response :success
    assert_select "h1", /Simple vs Compound Interest/
  end

  test "mortgage_terms sets cache headers" do
    get compare_mortgage_terms_url
    assert_response :success
    assert_match(/max-age=3600/, response.headers["Cache-Control"])
    assert_match(/public/, response.headers["Cache-Control"])
  end

  test "mortgage_terms has two mortgage calculator widgets" do
    get compare_mortgage_terms_url
    assert_response :success
    assert_select "[data-controller='mortgage-calculator']", 2
  end

  test "bmi_vs_body_fat has both calculator widgets" do
    get compare_bmi_vs_body_fat_url
    assert_response :success
    assert_select "[data-controller='bmi-calculator']", 1
    assert_select "[data-controller='body-fat-calculator']", 1
  end

  test "stocks_vs_crypto has both calculator widgets" do
    get compare_stocks_vs_crypto_url
    assert_response :success
    assert_select "[data-controller='stock-profit-calculator']", 1
    assert_select "[data-controller='crypto-profit-calculator']", 1
  end

  test "keto_vs_macros has both calculator widgets" do
    get compare_keto_vs_macros_url
    assert_response :success
    assert_select "[data-controller='keto-calculator']", 1
    assert_select "[data-controller='macro-calculator']", 1
  end

  test "simple_vs_compound has both calculator widgets" do
    get compare_simple_vs_compound_url
    assert_response :success
    assert_select "[data-controller='simple-interest-calculator']", 1
    assert_select "[data-controller='compound-interest-calculator']", 1
  end
end
