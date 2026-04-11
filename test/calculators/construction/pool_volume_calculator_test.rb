require "test_helper"

class Construction::PoolVolumeCalculatorTest < ActiveSupport::TestCase
  test "16 x 32 rectangular pool at 5 ft deep" do
    result = Construction::PoolVolumeCalculator.new(
      shape: "rectangular", length_ft: 32, width_ft: 16, average_depth_ft: 5
    ).call
    assert_equal true, result[:valid]
    # 32*16*5 = 2560 cu ft × 7.48 ≈ 19148 gal
    assert_in_delta 2560.0, result[:cubic_feet], 0.1
    assert_equal 19150, result[:gallons].to_i  # rounded
  end

  test "round pool uses pi/4 factor" do
    result = Construction::PoolVolumeCalculator.new(
      shape: "round", length_ft: 24, width_ft: 24, average_depth_ft: 4
    ).call
    # 24*24*(π/4)*4 = 1809 cu ft; × 7.48 ≈ 13528
    assert_in_delta 1809.6, result[:cubic_feet], 1
    assert_in_delta 13535, result[:gallons], 10
  end

  test "kidney uses 0.85 factor" do
    rect = Construction::PoolVolumeCalculator.new(
      shape: "rectangular", length_ft: 30, width_ft: 15, average_depth_ft: 5
    ).call
    kidney = Construction::PoolVolumeCalculator.new(
      shape: "kidney", length_ft: 30, width_ft: 15, average_depth_ft: 5
    ).call
    assert_in_delta rect[:gallons] * 0.85, kidney[:gallons], 2
  end

  test "invalid shape errors" do
    result = Construction::PoolVolumeCalculator.new(
      shape: "octagon", length_ft: 10, width_ft: 10, average_depth_ft: 5
    ).call
    assert_equal false, result[:valid]
  end

  test "zero depth errors" do
    result = Construction::PoolVolumeCalculator.new(
      shape: "rectangular", length_ft: 10, width_ft: 10, average_depth_ft: 0
    ).call
    assert_equal false, result[:valid]
  end
end
