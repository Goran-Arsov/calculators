require "test_helper"

class Gardening::TopsoilCalculatorTest < ActiveSupport::TestCase
  test "27 cubic feet is one cubic yard" do
    result = Gardening::TopsoilCalculator.new(length_ft: 9, width_ft: 9, depth_in: 4).call
    assert_equal true, result[:valid]
    assert_in_delta 27.0, result[:cubic_feet], 0.01
    assert_in_delta 1.0, result[:cubic_yards], 0.01
  end

  test "weight calculation" do
    result = Gardening::TopsoilCalculator.new(length_ft: 10, width_ft: 10, depth_in: 12).call
    assert_in_delta 100.0, result[:cubic_feet], 0.01
    assert_equal 7500, result[:pounds]
  end

  test "bags count rounds up" do
    result = Gardening::TopsoilCalculator.new(length_ft: 5, width_ft: 5, depth_in: 2).call
    # 4.166 cubic feet → 9 bags at 0.5 cf each
    assert_in_delta 4.17, result[:cubic_feet], 0.01
    assert_equal 9, result[:bags_40lb]
  end

  test "zero width errors" do
    result = Gardening::TopsoilCalculator.new(length_ft: 10, width_ft: 0, depth_in: 3).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Width must be greater than zero"
  end
end
