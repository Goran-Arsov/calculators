require "test_helper"

class Everyday::PricePerWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: grams ---

  test "$5.99 for 500g → $11.98/kg" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 5.99, weight: 500, unit: "g"
    ).call

    assert result[:valid]
    assert_in_delta 11.98, result[:price_per_kg], 0.01
  end

  test "price per 100g calculated correctly" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 10.0, weight: 1000, unit: "g"
    ).call

    assert result[:valid]
    assert_equal 1.0, result[:price_per_100g]
  end

  # --- Happy path: kilograms ---

  test "$10 for 2 kg → $5/kg" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 10.0, weight: 2, unit: "kg"
    ).call

    assert result[:valid]
    assert_equal 5.0, result[:price_per_kg]
  end

  # --- Happy path: ounces ---

  test "price in ounces converts to kg and lb" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 3.50, weight: 12, unit: "oz"
    ).call

    assert result[:valid]
    assert result[:price_per_kg] > 0
    assert result[:price_per_lb] > 0
    assert result[:price_per_kg] > result[:price_per_lb]
  end

  # --- Happy path: pounds ---

  test "$5 for 1 lb → $11.02/kg approximately" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 5.0, weight: 1, unit: "lb"
    ).call

    assert result[:valid]
    assert_in_delta 11.02, result[:price_per_kg], 0.05
    assert_equal 5.0, result[:price_per_lb]
  end

  # --- Validation errors ---

  test "error when price is zero" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 0, weight: 500, unit: "g"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Price must be greater than zero"
  end

  test "error when weight is negative" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 5.99, weight: -100, unit: "g"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Weight must be greater than zero"
  end

  test "error when unit is invalid" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 5.99, weight: 500, unit: "ton"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Unit must be g, kg, oz, or lb"
  end

  test "multiple errors at once" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 0, weight: 0, unit: "invalid"
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::PricePerWeightCalculator.new(
      price: "5.99", weight: "500", unit: "g"
    ).call

    assert result[:valid]
    assert_in_delta 11.98, result[:price_per_kg], 0.01
  end

  # --- Edge cases ---

  test "very small weight produces high per-kg price" do
    result = Everyday::PricePerWeightCalculator.new(
      price: 1.0, weight: 1, unit: "g"
    ).call

    assert result[:valid]
    assert_equal 1000.0, result[:price_per_kg]
  end
end
