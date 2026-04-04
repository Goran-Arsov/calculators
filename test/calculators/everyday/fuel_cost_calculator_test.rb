require "test_helper"

class Everyday::FuelCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "300 miles, 30 mpg, $3.50/gal → cost=35" do
    result = Everyday::FuelCostCalculator.new(
      distance: 300, fuel_economy_mpg: 30, fuel_price_per_gallon: 3.50
    ).call
    assert_nil result[:errors]
    assert_equal 35.0, result[:total_cost]
    assert_equal 10.0, result[:gallons_needed]
  end

  test "cost per mile calculated correctly" do
    result = Everyday::FuelCostCalculator.new(
      distance: 100, fuel_economy_mpg: 25, fuel_price_per_gallon: 4.00
    ).call
    assert_nil result[:errors]
    # 100/25 = 4 gallons * $4 = $16. Cost per mile = 16/100 = 0.16
    assert_equal 16.0, result[:total_cost]
    assert_equal 0.16, result[:cost_per_mile]
  end

  test "long road trip" do
    result = Everyday::FuelCostCalculator.new(
      distance: 1000, fuel_economy_mpg: 30, fuel_price_per_gallon: 3.00
    ).call
    assert_nil result[:errors]
    assert_in_delta 33.33, result[:gallons_needed], 0.01
    assert_equal 100.0, result[:total_cost]
  end

  # --- Validation errors ---

  test "error when distance is zero" do
    result = Everyday::FuelCostCalculator.new(
      distance: 0, fuel_economy_mpg: 30, fuel_price_per_gallon: 3.50
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "error when fuel economy is zero" do
    result = Everyday::FuelCostCalculator.new(
      distance: 300, fuel_economy_mpg: 0, fuel_price_per_gallon: 3.50
    ).call
    assert result[:errors].any?
    assert_includes result[:errors], "Fuel economy must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::FuelCostCalculator.new(
      distance: 300, fuel_economy_mpg: 30, fuel_price_per_gallon: 3.50
    )
    assert_equal [], calc.errors
  end
end
