require "test_helper"

class Construction::KitchenRemodelCalculatorTest < ActiveSupport::TestCase
  test "midrange 150 sqft" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "midrange"
    ).call
    assert_equal true, result[:valid]
    # 150 * 225 = 33750
    assert_equal 33_750, result[:base_cost]
    assert_equal 0, result[:add_on_cost]
    assert_equal 33_750, result[:total_cost]
  end

  test "custom cabinets multiply by 1.20" do
    default = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "midrange"
    ).call
    custom = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "midrange", custom_cabinets: true
    ).call
    assert_in_delta default[:base_cost] * 1.20, custom[:base_cost], 1
  end

  test "plumbing and electrical add flat amounts" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "midrange",
      move_plumbing: true, move_electrical: true
    ).call
    assert_equal 4000, result[:add_on_cost]
  end

  test "low and high estimates bracket total" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "midrange"
    ).call
    assert result[:low_estimate] < result[:total_cost]
    assert result[:high_estimate] > result[:total_cost]
  end

  test "breakdown sums to base" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 100, tier: "minor"
    ).call
    sum = result[:breakdown].values.sum
    assert_in_delta result[:base_cost], sum, 1
  end

  test "invalid tier errors" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 150, tier: "unicorn"
    ).call
    assert_equal false, result[:valid]
  end

  test "zero size errors" do
    result = Construction::KitchenRemodelCalculator.new(
      size_sqft: 0, tier: "midrange"
    ).call
    assert_equal false, result[:valid]
  end
end
