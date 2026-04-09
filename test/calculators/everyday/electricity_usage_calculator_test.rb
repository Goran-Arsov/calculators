require "test_helper"

class Everyday::ElectricityUsageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "single appliance: 100W, 8 hrs, $0.12 → daily=0.8, monthly=24, cost=$2.88" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.12,
      appliances: [{ name: "Light", watts: 100, hours_per_day: 8 }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 0.8, result[:total_daily_kwh]
    assert_equal 24.0, result[:total_monthly_kwh]
    assert_equal 2.88, result[:total_monthly_cost]
    assert_equal 1, result[:per_appliance_breakdown].size
    assert_equal "Light", result[:per_appliance_breakdown].first[:name]
  end

  test "multiple appliances sum correctly" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.10,
      appliances: [
        { name: "Fridge", watts: 150, hours_per_day: 24 },
        { name: "TV", watts: 100, hours_per_day: 5 }
      ]
    ).call
    assert_equal true, result[:valid]
    # Fridge: 150*24/1000 = 3.6 kWh/day, TV: 100*5/1000 = 0.5 kWh/day
    assert_in_delta 4.1, result[:total_daily_kwh], 0.001
    assert_in_delta 123.0, result[:total_monthly_kwh], 0.01
    assert_in_delta 12.3, result[:total_monthly_cost], 0.01
    assert_equal 2, result[:per_appliance_breakdown].size
  end

  test "high wattage appliance" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.15,
      appliances: [{ name: "AC", watts: 3000, hours_per_day: 10 }]
    ).call
    assert_equal true, result[:valid]
    # 3000*10/1000 = 30 kWh/day, 900 kWh/month, $135/month
    assert_equal 30.0, result[:total_daily_kwh]
    assert_equal 900.0, result[:total_monthly_kwh]
    assert_equal 135.0, result[:total_monthly_cost]
  end

  test "handles string inputs in appliances" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: "0.12",
      appliances: [{ name: "Lamp", watts: "60", hours_per_day: "6" }]
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 0.36, result[:total_daily_kwh], 0.001
  end

  # --- Validation errors ---

  test "error when cost per kwh is zero" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0,
      appliances: [{ name: "Light", watts: 100, hours_per_day: 8 }]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Cost per kWh must be greater than zero"
  end

  test "error when no appliances provided" do
    result = Everyday::ElectricityUsageCalculator.new(cost_per_kwh: 0.12, appliances: []).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one appliance is required"
  end

  test "error when appliance watts is zero" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.12,
      appliances: [{ name: "Broken", watts: 0, hours_per_day: 8 }]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Appliance 1 watts must be positive"
  end

  test "error when appliance hours is zero" do
    result = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.12,
      appliances: [{ name: "Unused", watts: 100, hours_per_day: 0 }]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Appliance 1 hours per day must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ElectricityUsageCalculator.new(
      cost_per_kwh: 0.12,
      appliances: [{ name: "Light", watts: 100, hours_per_day: 8 }]
    )
    assert_equal [], calc.errors
  end
end
