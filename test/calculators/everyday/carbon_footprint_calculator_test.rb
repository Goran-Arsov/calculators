require "test_helper"

class Everyday::CarbonFootprintCalculatorTest < ActiveSupport::TestCase
  test "calculates driving emissions" do
    result = Everyday::CarbonFootprintCalculator.new(driving_km_per_week: 200).call
    assert_equal true, result[:valid]
    # 200 km * 52 weeks * 0.21 kg/km = 2184 kg
    assert_equal 2184, result[:driving_kg]
  end

  test "calculates electricity emissions" do
    result = Everyday::CarbonFootprintCalculator.new(electricity_kwh_per_month: 900).call
    assert_equal true, result[:valid]
    # 900 kWh * 12 months * 0.42 kg/kWh = 4536 kg
    assert_equal 4536, result[:electricity_kg]
  end

  test "calculates flight emissions" do
    result = Everyday::CarbonFootprintCalculator.new(short_flights_per_year: 2, long_flights_per_year: 1).call
    assert_equal true, result[:valid]
    # Short: 2 * 1500 * 2 * 0.255 = 1530 kg
    # Long: 1 * 7000 * 2 * 0.255 = 3570 kg
    assert_equal 5100, result[:flights_kg]
  end

  test "calculates diet emissions for different diets" do
    vegan = Everyday::CarbonFootprintCalculator.new(diet: "vegan").call
    meat = Everyday::CarbonFootprintCalculator.new(diet: "meat_heavy").call
    assert_equal 1500, vegan[:diet_kg]
    assert_equal 3300, meat[:diet_kg]
  end

  test "calculates natural gas emissions" do
    result = Everyday::CarbonFootprintCalculator.new(natural_gas_therms_per_month: 50).call
    assert_equal true, result[:valid]
    # 50 * 12 * 5.3 = 3180 kg
    assert_equal 3180, result[:natural_gas_kg]
  end

  test "calculates total in tonnes" do
    result = Everyday::CarbonFootprintCalculator.new(
      driving_km_per_week: 200, electricity_kwh_per_month: 900
    ).call
    assert_equal true, result[:valid]
    expected_kg = 2184 + 4536 + 2500 # driving + electricity + default diet
    assert_equal expected_kg, result[:total_kg]
    assert_in_delta expected_kg / 1000.0, result[:total_tonnes], 0.01
  end

  test "includes comparison percentages" do
    result = Everyday::CarbonFootprintCalculator.new(driving_km_per_week: 200).call
    assert_equal true, result[:valid]
    assert result[:comparisons][:vs_global] > 0
    assert result[:comparisons][:vs_us] > 0
  end

  test "includes breakdown percentages" do
    result = Everyday::CarbonFootprintCalculator.new(
      driving_km_per_week: 200, electricity_kwh_per_month: 900
    ).call
    assert_equal true, result[:valid]
    total_pct = result[:breakdown].values.sum
    assert_in_delta 100.0, total_pct, 1.0
  end

  test "error for negative driving" do
    result = Everyday::CarbonFootprintCalculator.new(driving_km_per_week: -1).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Driving km per week cannot be negative"
  end

  test "error for invalid diet" do
    result = Everyday::CarbonFootprintCalculator.new(diet: "invalid").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid diet type"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CarbonFootprintCalculator.new
    assert_equal [], calc.errors
  end
end
