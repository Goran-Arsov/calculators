require "test_helper"

class Everyday::CostPerWearCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$200 jacket, 100 wears = $2/wear" do
    result = Everyday::CostPerWearCalculator.new(item_price: 200, estimated_wears: 100).call
    assert_nil result[:errors]
    assert_equal 2.0, result[:cost_per_wear]
  end

  test "comparison: main item is better value" do
    result = Everyday::CostPerWearCalculator.new(
      item_price: 200, estimated_wears: 200,
      alternative_price: 50, alternative_wears: 25
    ).call
    assert_nil result[:errors]
    assert_equal 1.0, result[:cost_per_wear]
    assert_equal 2.0, result[:alternative_cost_per_wear]
    assert_equal "Main item", result[:better_value]
  end

  test "comparison: alternative is better value" do
    result = Everyday::CostPerWearCalculator.new(
      item_price: 200, estimated_wears: 50,
      alternative_price: 30, alternative_wears: 30
    ).call
    assert_nil result[:errors]
    assert_equal 4.0, result[:cost_per_wear]
    assert_equal 1.0, result[:alternative_cost_per_wear]
    assert_equal "Alternative", result[:better_value]
  end

  test "comparison: tie" do
    result = Everyday::CostPerWearCalculator.new(
      item_price: 100, estimated_wears: 50,
      alternative_price: 40, alternative_wears: 20
    ).call
    assert_nil result[:errors]
    assert_equal 2.0, result[:cost_per_wear]
    assert_equal 2.0, result[:alternative_cost_per_wear]
    assert_equal "Tie", result[:better_value]
  end

  test "break-even wears calculated" do
    result = Everyday::CostPerWearCalculator.new(
      item_price: 200, estimated_wears: 200,
      alternative_price: 50, alternative_wears: 25
    ).call
    assert_nil result[:errors]
    assert_equal 100, result[:break_even_wears]  # 200 / 2.0 = 100
  end

  test "no alternative fields returns basic result" do
    result = Everyday::CostPerWearCalculator.new(item_price: 80, estimated_wears: 40).call
    assert_nil result[:errors]
    assert_equal 2.0, result[:cost_per_wear]
    assert_nil result[:alternative_cost_per_wear]
  end

  # --- Validation errors ---

  test "error when item price is zero" do
    result = Everyday::CostPerWearCalculator.new(item_price: 0, estimated_wears: 50).call
    assert result[:errors].any?
    assert_includes result[:errors], "Item price must be greater than zero"
  end

  test "error when estimated wears is zero" do
    result = Everyday::CostPerWearCalculator.new(item_price: 100, estimated_wears: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Estimated wears must be greater than zero"
  end

  test "error when alternative price set but wears not" do
    result = Everyday::CostPerWearCalculator.new(
      item_price: 100, estimated_wears: 50,
      alternative_price: 30, alternative_wears: 0
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Alternative wears must be greater than zero when alternative price is set"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerWearCalculator.new(item_price: "200", estimated_wears: "100").call
    assert_nil result[:errors]
    assert_equal 2.0, result[:cost_per_wear]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerWearCalculator.new(item_price: 100, estimated_wears: 50)
    assert_equal [], calc.errors
  end

  test "single wear" do
    result = Everyday::CostPerWearCalculator.new(item_price: 500, estimated_wears: 1).call
    assert_nil result[:errors]
    assert_equal 500.0, result[:cost_per_wear]
  end
end
