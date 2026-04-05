require "test_helper"

class Everyday::CostPerServingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$18 recipe, 6 servings = $3/serving" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 18, servings: 6).call
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_serving]
  end

  test "with markup: $18, 6 servings, 200% markup" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 18, servings: 6, markup_percent: 200).call
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_serving]
    assert_equal 9.0, result[:selling_price_per_serving]
    assert_equal 6.0, result[:profit_per_serving]
    assert_equal 54.0, result[:total_revenue]
    assert_equal 36.0, result[:total_profit]
  end

  test "zero markup yields same cost and selling price" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 20, servings: 4, markup_percent: 0).call
    assert_nil result[:errors]
    assert_equal 5.0, result[:cost_per_serving]
    assert_equal 5.0, result[:selling_price_per_serving]
    assert_equal 0.0, result[:profit_per_serving]
  end

  test "single serving" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 12, servings: 1).call
    assert_nil result[:errors]
    assert_equal 12.0, result[:cost_per_serving]
  end

  test "fractional servings" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 10, servings: 3).call
    assert_nil result[:errors]
    assert_equal 3.33, result[:cost_per_serving]
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 0, servings: 6).call
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "error when servings is zero" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 18, servings: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Number of servings must be greater than zero"
  end

  test "error when markup is negative" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 18, servings: 6, markup_percent: -10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Markup percent cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerServingCalculator.new(total_cost: "18", servings: "6", markup_percent: "100").call
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_serving]
    assert_equal 6.0, result[:selling_price_per_serving]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerServingCalculator.new(total_cost: 18, servings: 6)
    assert_equal [], calc.errors
  end

  test "very high markup" do
    result = Everyday::CostPerServingCalculator.new(total_cost: 10, servings: 5, markup_percent: 500).call
    assert_nil result[:errors]
    assert_equal 2.0, result[:cost_per_serving]
    assert_equal 12.0, result[:selling_price_per_serving]
  end
end
