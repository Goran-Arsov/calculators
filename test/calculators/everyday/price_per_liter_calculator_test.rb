require "test_helper"

class Everyday::PricePerLiterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$4.50 for 1.5 liters = $3/liter" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 4.50, volume: 1.5, unit: "L").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.0, result[:price_per_liter]
  end

  test "milliliters conversion: 500 mL" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 3.0, volume: 500, unit: "mL").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 6.0, result[:price_per_liter]
    assert_equal 0.5, result[:volume_in_liters]
  end

  test "gallon conversion" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 3.50, volume: 1, unit: "gal").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 0.9246, result[:price_per_liter], 0.001
    assert_in_delta 3.7854, result[:volume_in_liters], 0.001
  end

  test "fluid ounce conversion" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 2.00, volume: 16, unit: "fl_oz").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 0.4732, result[:volume_in_liters], 0.001
  end

  test "price per mL is price per liter divided by 1000" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 5.0, volume: 1, unit: "L").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 5.0, result[:price_per_liter]
    assert_equal 0.005, result[:price_per_ml]
  end

  test "price per gallon calculated correctly" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 1.0, volume: 1, unit: "L").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 3.79, result[:price_per_gallon], 0.01
  end

  # --- Validation errors ---

  test "error when total price is zero" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 0, volume: 1, unit: "L").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total price must be greater than zero"
  end

  test "error when volume is zero" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 5, volume: 0, unit: "L").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Volume must be greater than zero"
  end

  test "error when unit is invalid" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 5, volume: 1, unit: "quarts").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Unit must be L, mL, gal, or fl_oz"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::PricePerLiterCalculator.new(total_price: "4.50", volume: "1.5", unit: "L").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.0, result[:price_per_liter]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::PricePerLiterCalculator.new(total_price: 5, volume: 1, unit: "L")
    assert_equal [], calc.errors
  end

  test "returns unit in result" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 5, volume: 1, unit: "gal").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "gal", result[:unit]
  end

  test "very small volume in mL" do
    result = Everyday::PricePerLiterCalculator.new(total_price: 10, volume: 30, unit: "mL").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_in_delta 333.3333, result[:price_per_liter], 0.01
  end
end
