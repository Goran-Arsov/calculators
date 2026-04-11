require "test_helper"

class Gardening::MulchCalculatorTest < ActiveSupport::TestCase
  test "10 × 10 × 3 inches gives 25 cubic feet" do
    result = Gardening::MulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3).call
    assert_equal true, result[:valid]
    assert_in_delta 25.0, result[:cubic_feet], 0.001
    assert_in_delta 0.93, result[:cubic_yards], 0.01
    assert_equal 13, result[:bags_2cf]
    assert_equal 100.0, result[:area_sqft]
  end

  test "bags_2cf rounds up" do
    result = Gardening::MulchCalculator.new(length_ft: 3, width_ft: 3, depth_in: 3).call
    assert_equal 2, result[:bags_2cf]
  end

  test "zero length returns errors" do
    result = Gardening::MulchCalculator.new(length_ft: 0, width_ft: 5, depth_in: 3).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "negative depth returns errors" do
    result = Gardening::MulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Depth must be greater than zero"
  end
end
