require "test_helper"

class Finance::BreakEvenCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "fixed=10000, price=50, variable=30 → break-even=500 units" do
    result = Finance::BreakEvenCalculator.new(
      fixed_costs: 10000, price_per_unit: 50, variable_cost_per_unit: 30
    ).call
    assert result[:valid]
    assert_equal 500.0, result[:break_even_units]
    assert_equal 25000.0, result[:break_even_revenue]
    assert_equal 20.0, result[:contribution_margin]
  end

  test "fixed=5000, price=100, variable=50 → break-even=100 units" do
    result = Finance::BreakEvenCalculator.new(
      fixed_costs: 5000, price_per_unit: 100, variable_cost_per_unit: 50
    ).call
    assert result[:valid]
    assert_equal 100.0, result[:break_even_units]
  end

  test "zero variable cost: entire price is contribution margin" do
    result = Finance::BreakEvenCalculator.new(
      fixed_costs: 1000, price_per_unit: 25, variable_cost_per_unit: 0
    ).call
    assert result[:valid]
    assert_equal 40.0, result[:break_even_units]
    assert_equal 25.0, result[:contribution_margin]
  end

  # --- Validation errors ---

  test "error when price per unit is less than variable cost" do
    result = Finance::BreakEvenCalculator.new(
      fixed_costs: 10000, price_per_unit: 20, variable_cost_per_unit: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Price per unit must be greater than variable cost per unit"
  end

  test "error when fixed costs are zero" do
    result = Finance::BreakEvenCalculator.new(
      fixed_costs: 0, price_per_unit: 50, variable_cost_per_unit: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Fixed costs must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::BreakEvenCalculator.new(
      fixed_costs: 10000, price_per_unit: 50, variable_cost_per_unit: 30
    )
    assert_equal [], calc.errors
  end
end
