require "test_helper"

class Geography::BearingCalculatorTest < ActiveSupport::TestCase
  test "NYC to London initial bearing is roughly 51 degrees" do
    result = Geography::BearingCalculator.new(
      lat1: 40.7128, lon1: -74.0060,
      lat2: 51.5074, lon2: -0.1278
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 51, result[:initial_bearing], 2
  end

  test "back bearing is 180 offset for short paths" do
    result = Geography::BearingCalculator.new(
      lat1: 0, lon1: 0, lat2: 0, lon2: 1
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 90, result[:initial_bearing], 0.5
    assert_in_delta 270, result[:back_bearing], 0.5
  end

  test "due north returns 0 and N compass point" do
    result = Geography::BearingCalculator.new(
      lat1: 0, lon1: 0, lat2: 10, lon2: 0
    ).call
    assert_in_delta 0, result[:initial_bearing], 0.01
    assert_equal "N", result[:compass]
  end

  test "same point returns error" do
    result = Geography::BearingCalculator.new(
      lat1: 40, lon1: -74, lat2: 40, lon2: -74
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Points must be different to compute a bearing"
  end

  test "compass point for 45 degrees is NE" do
    result = Geography::BearingCalculator.new(
      lat1: 0, lon1: 0, lat2: 0.001, lon2: 0.001
    ).call
    assert_equal "NE", result[:compass]
  end
end
