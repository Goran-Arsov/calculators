require "test_helper"

class Construction::CarpetCalculatorTest < ActiveSupport::TestCase
  test "12x15 room at 10% waste" do
    result = Construction::CarpetCalculator.new(length_ft: 15, width_ft: 12, waste_pct: 10).call
    assert_equal true, result[:valid]
    assert_in_delta 180.0, result[:area_sqft], 0.01
    assert_in_delta 198.0, result[:area_with_waste_sqft], 0.01
    assert_in_delta 22.0, result[:square_yards], 0.01
  end

  test "room wider than roll needs seam" do
    result = Construction::CarpetCalculator.new(length_ft: 20, width_ft: 15).call
    assert_equal true, result[:needs_seam]
  end

  test "room narrower than roll does not need seam" do
    result = Construction::CarpetCalculator.new(length_ft: 20, width_ft: 10).call
    assert_equal false, result[:needs_seam]
  end

  test "cost calculation" do
    result = Construction::CarpetCalculator.new(
      length_ft: 15, width_ft: 12, price_per_sqyd: 35
    ).call
    assert_in_delta 770.0, result[:total_cost], 0.01  # 22 sqyd × $35
  end

  test "zero length errors" do
    result = Construction::CarpetCalculator.new(length_ft: 0, width_ft: 10).call
    assert_equal false, result[:valid]
  end
end
