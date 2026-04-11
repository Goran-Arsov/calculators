require "test_helper"

class Geography::MapScaleCalculatorTest < ActiveSupport::TestCase
  test "1:50000 with 5 cm equals 2.5 km" do
    result = Geography::MapScaleCalculator.new(
      scale_ratio: 50_000, map_distance: 5, map_unit: "cm"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 2500.0, result[:real_meters], 0.01
    assert_in_delta 2.5, result[:real_km], 0.0001
    assert_in_delta 1.553, result[:real_miles], 0.01
  end

  test "1:25000 with 4 cm equals 1 km" do
    result = Geography::MapScaleCalculator.new(
      scale_ratio: 25_000, map_distance: 4, map_unit: "cm"
    ).call
    assert_in_delta 1000.0, result[:real_meters], 0.01
  end

  test "inch unit works for imperial maps" do
    result = Geography::MapScaleCalculator.new(
      scale_ratio: 24_000, map_distance: 1, map_unit: "in"
    ).call
    # 1 inch × 24000 = 24000 inches = 2000 ft
    assert_in_delta 2000, result[:real_feet], 0.5
  end

  test "zero scale returns errors" do
    result = Geography::MapScaleCalculator.new(
      scale_ratio: 0, map_distance: 5, map_unit: "cm"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Scale ratio must be greater than zero"
  end

  test "invalid unit returns errors" do
    result = Geography::MapScaleCalculator.new(
      scale_ratio: 50_000, map_distance: 5, map_unit: "foo"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Map unit must be cm, mm, or in"
  end
end
