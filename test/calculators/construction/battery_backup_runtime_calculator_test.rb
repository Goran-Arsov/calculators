require "test_helper"

class Construction::BatteryBackupRuntimeCalculatorTest < ActiveSupport::TestCase
  test "13.5 kWh Powerwall at 1000 W load" do
    result = Construction::BatteryBackupRuntimeCalculator.new(
      battery_kwh: 13.5, load_watts: 1000, depth_of_discharge: 100, inverter_efficiency: 92
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 13.5 × 1000 × 1.0 × 0.92 = 12420 Wh / 1000 W = 12.42 h
    assert_in_delta 12.42, result[:runtime_hours], 0.01
  end

  test "higher load = shorter runtime" do
    low = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 500).call
    high = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 2000).call
    assert high[:runtime_hours] < low[:runtime_hours]
  end

  test "lower DoD reduces usable energy" do
    full = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000, depth_of_discharge: 100).call
    lead_acid = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000, depth_of_discharge: 50).call
    assert_in_delta full[:runtime_hours] / 2.0, lead_acid[:runtime_hours], 0.01
  end

  test "lower inverter efficiency reduces runtime" do
    good = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000, inverter_efficiency: 95).call
    bad = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000, inverter_efficiency: 85).call
    assert bad[:runtime_hours] < good[:runtime_hours]
  end

  test "runtime display format" do
    result = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 2000, depth_of_discharge: 100, inverter_efficiency: 100).call
    # 10000 / 2000 = 5 h 0 min
    assert_equal "5 h 0 min", result[:runtime_display]
  end

  test "usable energy excludes DoD and inverter losses" do
    result = Construction::BatteryBackupRuntimeCalculator.new(
      battery_kwh: 10, load_watts: 1000, depth_of_discharge: 80, inverter_efficiency: 90
    ).call
    # 10 × 0.80 × 0.90 = 7.2 kWh usable
    assert_in_delta 7.2, result[:usable_kwh], 0.01
  end

  test "error when battery is zero" do
    result = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 0, load_watts: 1000).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Battery capacity must be greater than zero"
  end

  test "error when DoD out of range" do
    result = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000, depth_of_discharge: 120).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Depth of discharge must be between 10 and 100"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::BatteryBackupRuntimeCalculator.new(battery_kwh: 10, load_watts: 1000)
    assert_equal [], calc.errors
  end
end
