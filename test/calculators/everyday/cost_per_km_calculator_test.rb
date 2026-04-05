require "test_helper"

class Everyday::CostPerKmCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "500 km, 40 liters, $1.50/liter → cost per km = $0.12" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 500, fuel_used_liters: 40, fuel_price_per_liter: 1.50
    ).call

    assert result[:valid]
    assert_equal 60.0, result[:total_fuel_cost]
    assert_equal 0.12, result[:cost_per_km]
  end

  test "cost per mile is higher than cost per km" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 100, fuel_used_liters: 8, fuel_price_per_liter: 1.50
    ).call

    assert result[:valid]
    assert result[:cost_per_mile] > result[:cost_per_km]
  end

  test "distance in miles is less than distance in km" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 100, fuel_used_liters: 10, fuel_price_per_liter: 1.50
    ).call

    assert result[:valid]
    assert_in_delta 62.14, result[:distance_miles], 0.01
  end

  test "large trip calculates correctly" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 10000, fuel_used_liters: 800, fuel_price_per_liter: 2.00
    ).call

    assert result[:valid]
    assert_equal 1600.0, result[:total_fuel_cost]
    assert_equal 0.16, result[:cost_per_km]
  end

  # --- Validation errors ---

  test "error when distance is zero" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 0, fuel_used_liters: 40, fuel_price_per_liter: 1.50
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "error when fuel used is negative" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 500, fuel_used_liters: -10, fuel_price_per_liter: 1.50
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Fuel used must be greater than zero"
  end

  test "error when fuel price is zero" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 500, fuel_used_liters: 40, fuel_price_per_liter: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Fuel price must be greater than zero"
  end

  test "multiple errors returned at once" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: 0, fuel_used_liters: 0, fuel_price_per_liter: 0
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerKmCalculator.new(
      distance_km: "500", fuel_used_liters: "40", fuel_price_per_liter: "1.50"
    ).call

    assert result[:valid]
    assert_equal 0.12, result[:cost_per_km]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerKmCalculator.new(
      distance_km: 500, fuel_used_liters: 40, fuel_price_per_liter: 1.50
    )
    assert_equal [], calc.errors
  end
end
