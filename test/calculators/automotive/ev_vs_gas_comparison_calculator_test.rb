require "test_helper"

class Automotive::EvVsGasComparisonCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard comparison" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13,
      ev_annual_maintenance: 500, gas_annual_maintenance: 1200,
      comparison_years: 5
    ).call
    assert result[:valid]
    # Gas fuel: 12000/28 * 3.50 = 1500
    assert_in_delta 1_500.0, result[:gas_fuel_cost_annual], 1.0
    # EV fuel: 12000/100 * 30 * 0.13 = 468
    assert_in_delta 468.0, result[:ev_fuel_cost_annual], 1.0
    assert result[:fuel_savings_annual] > 0
    assert result[:co2_savings_annual_lbs] > 0
  end

  # --- EV is cheaper to operate ---

  test "EV fuel cost is lower than gas" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 15_000, gas_mpg: 25, gas_price_per_gallon: 4.00,
      ev_efficiency_kwh_per_100mi: 28, electricity_rate_per_kwh: 0.12
    ).call
    assert result[:valid]
    assert result[:ev_fuel_cost_annual] < result[:gas_fuel_cost_annual]
    assert result[:ev_cost_per_mile] < result[:gas_cost_per_mile]
  end

  # --- Break-even with price difference ---

  test "break-even calculation with price premium" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13,
      ev_purchase_price: 40_000, gas_purchase_price: 30_000,
      comparison_years: 5
    ).call
    assert result[:valid]
    assert result[:break_even_years] > 0
  end

  # --- CO2 savings ---

  test "EV produces less CO2 than gas" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13
    ).call
    assert result[:valid]
    assert result[:ev_co2_annual_lbs] < result[:gas_co2_annual_lbs]
    assert result[:co2_savings_annual_lbs] > 0
  end

  # --- Validation errors ---

  test "zero annual miles returns error" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 0, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Annual miles must be positive"
  end

  test "zero gas MPG returns error" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 0, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gas MPG must be positive"
  end

  test "zero electricity rate returns error" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Electricity rate must be positive"
  end

  test "negative maintenance returns error" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: 12_000, gas_mpg: 28, gas_price_per_gallon: 3.50,
      ev_efficiency_kwh_per_100mi: 30, electricity_rate_per_kwh: 0.13,
      ev_annual_maintenance: -100
    ).call
    refute result[:valid]
    assert_includes result[:errors], "EV maintenance cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::EvVsGasComparisonCalculator.new(
      annual_miles: "12000", gas_mpg: "28", gas_price_per_gallon: "3.50",
      ev_efficiency_kwh_per_100mi: "30", electricity_rate_per_kwh: "0.13"
    ).call
    assert result[:valid]
  end
end
