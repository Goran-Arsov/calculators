require "test_helper"

class Gardening::CompostCalculatorTest < ActiveSupport::TestCase
  test "10x10 at 2 inches gives 16.67 cubic feet" do
    result = Gardening::CompostCalculator.new(length_ft: 10, width_ft: 10, depth_in: 2).call
    assert_equal true, result[:valid]
    assert_in_delta 16.67, result[:cubic_feet], 0.01
    assert_equal 17, result[:bags]
  end

  test "100 sq ft at 3 inches gives 1125 pounds at 45 lb/cf" do
    result = Gardening::CompostCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3).call
    assert_equal 1125, result[:pounds]
  end

  test "zero area errors" do
    result = Gardening::CompostCalculator.new(length_ft: 10, width_ft: 0, depth_in: 2).call
    assert_equal false, result[:valid]
  end
end
