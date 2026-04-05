require "test_helper"

class Construction::LumberCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "2x6x8 → 8 board feet" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 8.0, result[:board_feet_each]
  end

  test "1x12x1 → 1 board foot" do
    result = Construction::LumberCalculator.new(thickness_in: 1, width_in: 12, length_ft: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1.0, result[:board_feet_each]
  end

  test "quantity multiplies board feet" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8, quantity: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 80.0, result[:total_board_feet]
    assert_equal 10, result[:quantity]
  end

  test "cost calculated correctly" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8, quantity: 5, price_per_bf: 5.0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 8 bf each * $5 = $40 each, 40 bf total * $5 = $200 total
    assert_equal 40.0, result[:cost_each]
    assert_equal 200.0, result[:total_cost]
  end

  test "linear feet calculated correctly" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 4, length_ft: 10, quantity: 3).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 30.0, result[:total_linear_feet]
  end

  test "fractional dimensions work" do
    # 4/4 (1") x 8" x 6' = (1 * 8 * 6) / 12 = 4 bf
    result = Construction::LumberCalculator.new(thickness_in: 1, width_in: 8, length_ft: 6).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4.0, result[:board_feet_each]
  end

  test "zero price results in zero cost" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8, price_per_bf: 0).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:total_cost]
  end

  test "string inputs are coerced" do
    result = Construction::LumberCalculator.new(thickness_in: "2", width_in: "6", length_ft: "8", quantity: "5", price_per_bf: "5").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 8.0, result[:board_feet_each]
  end

  # --- Validation errors ---

  test "error when thickness is zero" do
    result = Construction::LumberCalculator.new(thickness_in: 0, width_in: 6, length_ft: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Thickness must be greater than zero"
  end

  test "error when quantity is zero" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8, quantity: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Quantity must be at least 1"
  end

  test "error when price is negative" do
    result = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8, price_per_bf: -1).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Price per board foot cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::LumberCalculator.new(thickness_in: 2, width_in: 6, length_ft: 8)
    assert_equal [], calc.errors
  end
end
