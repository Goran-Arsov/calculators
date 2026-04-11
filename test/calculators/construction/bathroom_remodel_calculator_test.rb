require "test_helper"

class Construction::BathroomRemodelCalculatorTest < ActiveSupport::TestCase
  test "midrange 40 sqft" do
    result = Construction::BathroomRemodelCalculator.new(
      size_sqft: 40, tier: "midrange"
    ).call
    assert_equal true, result[:valid]
    # 40 * 275 = 11_000
    assert_equal 11_000, result[:base_cost]
    assert_equal 0, result[:add_on_cost]
  end

  test "add_shower and walk_in_tub stack" do
    result = Construction::BathroomRemodelCalculator.new(
      size_sqft: 40, tier: "midrange",
      move_plumbing: true, add_shower: true, walk_in_tub: true
    ).call
    # 1500 + 3000 + 5000 = 9500
    assert_equal 9_500, result[:add_on_cost]
  end

  test "luxury tier is 650 per sqft" do
    result = Construction::BathroomRemodelCalculator.new(
      size_sqft: 50, tier: "luxury"
    ).call
    assert_equal 32_500, result[:base_cost]
  end

  test "breakdown sums to base" do
    result = Construction::BathroomRemodelCalculator.new(
      size_sqft: 40, tier: "midrange"
    ).call
    sum = result[:breakdown].values.sum
    assert_in_delta result[:base_cost], sum, 1
  end

  test "zero size errors" do
    result = Construction::BathroomRemodelCalculator.new(
      size_sqft: 0, tier: "midrange"
    ).call
    assert_equal false, result[:valid]
  end
end
