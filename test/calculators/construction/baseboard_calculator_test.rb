require "test_helper"

class Construction::BaseboardCalculatorTest < ActiveSupport::TestCase
  test "12x15 room with 2 doors" do
    result = Construction::BaseboardCalculator.new(
      length_ft: 15, width_ft: 12, doors: 2, waste_pct: 10, stick_length_ft: 8
    ).call
    assert_equal true, result[:valid]
    # perimeter = 2*(15+12) = 54
    # doors = 2*3 = 6
    # lf = 48
    # with waste = 52.8
    # sticks = ceil(52.8/8) = 7
    assert_in_delta 54.0, result[:perimeter_ft], 0.01
    assert_in_delta 6.0, result[:door_deduction_ft], 0.01
    assert_in_delta 48.0, result[:linear_feet], 0.01
    assert_in_delta 52.8, result[:linear_feet_with_waste], 0.01
    assert_equal 7, result[:sticks]
  end

  test "cost calculation" do
    result = Construction::BaseboardCalculator.new(
      length_ft: 10, width_ft: 10, doors: 0, waste_pct: 0, price_per_foot: 2
    ).call
    # 40 lf × $2 = $80
    assert_in_delta 80.0, result[:total_cost], 0.01
  end

  test "deducts full door count from perimeter" do
    result = Construction::BaseboardCalculator.new(
      length_ft: 10, width_ft: 10, doors: 3, waste_pct: 0
    ).call
    assert_in_delta 31.0, result[:linear_feet], 0.01  # 40 - 9
  end

  test "never goes negative" do
    result = Construction::BaseboardCalculator.new(
      length_ft: 5, width_ft: 5, doors: 10
    ).call
    assert_equal 0.0, result[:linear_feet]
  end

  test "zero width errors" do
    result = Construction::BaseboardCalculator.new(
      length_ft: 10, width_ft: 0, doors: 1
    ).call
    assert_equal false, result[:valid]
  end
end
