require "test_helper"

class Everyday::UnitPriceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "product A is cheaper" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5.00, quantity_a: 10, price_b: 8.00, quantity_b: 10).call
    assert_nil result[:errors]
    assert_equal 0.5, result[:unit_price_a]
    assert_equal 0.8, result[:unit_price_b]
    assert_equal "A", result[:better_deal]
  end

  test "product B is cheaper" do
    result = Everyday::UnitPriceCalculator.new(price_a: 3.99, quantity_a: 12, price_b: 5.49, quantity_b: 24).call
    assert_nil result[:errors]
    assert_equal 0.3325, result[:unit_price_a]
    assert_equal 0.2288, result[:unit_price_b] # 5.49/24 = 0.22875 -> 0.2288
    assert_equal "B", result[:better_deal]
  end

  test "tie when unit prices are equal" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5.00, quantity_a: 10, price_b: 10.00, quantity_b: 20).call
    assert_nil result[:errors]
    assert_equal 0.5, result[:unit_price_a]
    assert_equal 0.5, result[:unit_price_b]
    assert_equal "Tie", result[:better_deal]
  end

  test "savings per unit and percent" do
    result = Everyday::UnitPriceCalculator.new(price_a: 2.00, quantity_a: 1, price_b: 3.00, quantity_b: 1).call
    assert_nil result[:errors]
    assert_equal 1.0, result[:savings_per_unit]
    assert_in_delta 33.33, result[:savings_percent], 0.1
  end

  test "custom unit label" do
    result = Everyday::UnitPriceCalculator.new(price_a: 4.99, quantity_a: 16, price_b: 3.49, quantity_b: 12, unit: "oz").call
    assert_nil result[:errors]
    assert_equal "oz", result[:unit]
  end

  test "product details are returned" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5.00, quantity_a: 10, price_b: 8.00, quantity_b: 20).call
    assert_nil result[:errors]
    assert_equal({ price: 5.0, quantity: 10.0 }, result[:product_a])
    assert_equal({ price: 8.0, quantity: 20.0 }, result[:product_b])
  end

  test "small quantities with large prices" do
    result = Everyday::UnitPriceCalculator.new(price_a: 150, quantity_a: 0.5, price_b: 250, quantity_b: 1).call
    assert_nil result[:errors]
    assert_equal 300.0, result[:unit_price_a]
    assert_equal 250.0, result[:unit_price_b]
    assert_equal "B", result[:better_deal]
  end

  test "fractional quantities" do
    result = Everyday::UnitPriceCalculator.new(price_a: 2.50, quantity_a: 0.75, price_b: 4.00, quantity_b: 1.5).call
    assert_nil result[:errors]
    assert_in_delta 3.3333, result[:unit_price_a], 0.001
    assert_in_delta 2.6667, result[:unit_price_b], 0.001
    assert_equal "B", result[:better_deal]
  end

  # --- Validation errors ---

  test "error when price A is zero" do
    result = Everyday::UnitPriceCalculator.new(price_a: 0, quantity_a: 10, price_b: 5, quantity_b: 10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Price A must be greater than zero"
  end

  test "error when quantity A is zero" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5, quantity_a: 0, price_b: 5, quantity_b: 10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Quantity A must be greater than zero"
  end

  test "error when price B is negative" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5, quantity_a: 10, price_b: -3, quantity_b: 10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Price B must be greater than zero"
  end

  test "error when quantity B is zero" do
    result = Everyday::UnitPriceCalculator.new(price_a: 5, quantity_a: 10, price_b: 5, quantity_b: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Quantity B must be greater than zero"
  end

  test "string coercion for prices and quantities" do
    result = Everyday::UnitPriceCalculator.new(price_a: "5", quantity_a: "10", price_b: "8", quantity_b: "20").call
    assert_nil result[:errors]
    assert_equal 0.5, result[:unit_price_a]
    assert_equal 0.4, result[:unit_price_b]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::UnitPriceCalculator.new(price_a: 5, quantity_a: 10, price_b: 8, quantity_b: 20)
    assert_equal [], calc.errors
  end
end
