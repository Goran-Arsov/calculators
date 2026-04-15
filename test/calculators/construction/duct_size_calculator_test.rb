require "test_helper"

class Construction::DuctSizeCalculatorTest < ActiveSupport::TestCase
  test "400 CFM at 700 fpm → round duct" do
    result = Construction::DuctSizeCalculator.new(cfm: 400, velocity_fpm: 700).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # area = 400/700 = 0.571 sq ft = 82.3 sq in → d = 2×√(82.3/π) ≈ 10.24
    assert_in_delta 10.24, result[:round_diameter_in], 0.05
  end

  test "rectangular duct with 2:1 aspect ratio" do
    result = Construction::DuctSizeCalculator.new(cfm: 800, velocity_fpm: 800, aspect_ratio: 2).call
    # area = 1.0 sq ft = 144 sq in
    # short = √(144/2) = √72 ≈ 8.49, long = 16.97
    assert_in_delta 8.49, result[:rect_short_in], 0.05
    assert_in_delta 16.97, result[:rect_long_in], 0.05
  end

  test "higher velocity → smaller duct" do
    low = Construction::DuctSizeCalculator.new(cfm: 400, velocity_fpm: 500).call
    high = Construction::DuctSizeCalculator.new(cfm: 400, velocity_fpm: 900).call
    assert high[:round_diameter_in] < low[:round_diameter_in]
  end

  test "higher CFM → larger duct" do
    small = Construction::DuctSizeCalculator.new(cfm: 200, velocity_fpm: 700).call
    large = Construction::DuctSizeCalculator.new(cfm: 1200, velocity_fpm: 700).call
    assert large[:round_diameter_in] > small[:round_diameter_in]
  end

  test "equivalent round diameter is smaller than long side" do
    result = Construction::DuctSizeCalculator.new(cfm: 800, velocity_fpm: 800, aspect_ratio: 3).call
    assert result[:equivalent_round_in] < result[:rect_long_in]
  end

  test "error when CFM is zero" do
    result = Construction::DuctSizeCalculator.new(cfm: 0, velocity_fpm: 700).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "CFM must be greater than zero"
  end

  test "error when aspect ratio below 1" do
    result = Construction::DuctSizeCalculator.new(cfm: 400, velocity_fpm: 700, aspect_ratio: 0.5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Aspect ratio must be at least 1.0"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DuctSizeCalculator.new(cfm: 400, velocity_fpm: 700)
    assert_equal [], calc.errors
  end
end
