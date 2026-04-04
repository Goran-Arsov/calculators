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
      assert_select "h1", /Circle Calculator/
    end

    test "should get exponent" do
      get math_exponent_url
      assert_response :success
      assert_select "h1", /Exponent Calculator/
    end

    test "should get pythagorean" do
      get math_pythagorean_url
      assert_response :success
      assert_select "h1", /Pythagorean/
    end

    test "should get quadratic" do
      get math_quadratic_url
      assert_response :success
      assert_select "h1", /Quadratic/
    end

    test "should get standard_deviation" do
      get math_standard_deviation_url
      assert_response :success
      assert_select "h1", /Standard Deviation/
    end

    test "should get gcd_lcm" do
      get math_gcd_lcm_url
      assert_response :success
      assert_select "h1", /GCD/
    end

    test "should get sample_size" do
      get math_sample_size_url
      assert_response :success
      assert_select "h1", /Sample Size/
    end

    test "should get aspect_ratio" do
      get math_aspect_ratio_url
      assert_response :success
      assert_select "h1", /Aspect Ratio/
    end
  end
end
