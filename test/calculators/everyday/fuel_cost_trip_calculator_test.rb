require "test_helper"

class Everyday::FuelCostTripCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: metric ---

  test "400 km at 8 L/100km, $1.50/liter → $48 trip cost" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 400, fuel_efficiency: 8, fuel_price: 1.50,
      efficiency_unit: "l_per_100km", distance_unit: "km", price_unit: "per_liter"
    ).call

    assert result[:valid]
    assert_equal 48.0, result[:trip_cost]
    assert_equal 32.0, result[:fuel_needed_liters]
  end

  # --- Happy path: imperial (MPG) ---

  test "300 miles at 25 MPG, $3.50/gallon" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 300, fuel_efficiency: 25, fuel_price: 3.50,
      efficiency_unit: "mpg", distance_unit: "miles", price_unit: "per_gallon"
    ).call

    assert result[:valid]
    assert_in_delta 42.0, result[:trip_cost], 0.5
    assert_in_delta 12.0, result[:fuel_needed_gallons], 0.1
  end

  # --- Happy path: km/L ---

  test "200 km at 12.5 km/L, $1.40/liter" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 200, fuel_efficiency: 12.5, fuel_price: 1.40,
      efficiency_unit: "km_per_l", distance_unit: "km", price_unit: "per_liter"
    ).call

    assert result[:valid]
    assert_in_delta 22.40, result[:trip_cost], 0.01
    assert_in_delta 16.0, result[:fuel_needed_liters], 0.01
  end

  test "cost per km and cost per mile are both positive" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 500, fuel_efficiency: 7, fuel_price: 1.60,
      efficiency_unit: "l_per_100km", distance_unit: "km", price_unit: "per_liter"
    ).call

    assert result[:valid]
    assert result[:cost_per_km] > 0
    assert result[:cost_per_mile] > result[:cost_per_km]
  end

  # --- Validation errors ---

  test "error when distance is zero" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 0, fuel_efficiency: 8, fuel_price: 1.50
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "error when fuel efficiency is zero" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 400, fuel_efficiency: 0, fuel_price: 1.50
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Fuel efficiency must be greater than zero"
  end

  test "error when efficiency unit is invalid" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 400, fuel_efficiency: 8, fuel_price: 1.50,
      efficiency_unit: "gallons_per_100km"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid efficiency unit"
  end

  test "multiple validation errors" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: 0, fuel_efficiency: 0, fuel_price: 0,
      efficiency_unit: "invalid", distance_unit: "invalid", price_unit: "invalid"
    ).call

    refute result[:valid]
    assert result[:errors].size >= 3
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::FuelCostTripCalculator.new(
      distance: "400", fuel_efficiency: "8", fuel_price: "1.50"
    ).call

    assert result[:valid]
    assert_equal 48.0, result[:trip_cost]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::FuelCostTripCalculator.new(
      distance: 400, fuel_efficiency: 8, fuel_price: 1.50
    )
    assert_equal [], calc.errors
  end
end
