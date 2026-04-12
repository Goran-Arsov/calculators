require "test_helper"

class Automotive::EvChargingCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: 75 kWh battery 10% to 80% at $0.13/kWh" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, current_charge_pct: 10,
      target_charge_pct: 80, electricity_rate_per_kwh: 0.13,
      charger_type: "level2", charger_efficiency_pct: 90
    ).call
    assert result[:valid]
    # Energy needed: 75 * (0.80 - 0.10) = 52.5 kWh
    assert_in_delta 52.5, result[:energy_needed_kwh], 0.1
    # From grid: 52.5 / 0.90 = 58.33
    assert_in_delta 58.33, result[:energy_from_grid_kwh], 0.1
    # Cost: 58.33 * 0.13 = 7.58
    assert_in_delta 7.58, result[:charging_cost], 0.1
    assert result[:charge_time_hours] > 0
    assert result[:cost_per_mile] > 0
    assert result[:miles_added] > 0
  end

  # --- DC fast charging ---

  test "DC fast charging is faster" do
    level2 = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, current_charge_pct: 10,
      target_charge_pct: 80, electricity_rate_per_kwh: 0.13,
      charger_type: "level2"
    ).call
    dc_fast = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, current_charge_pct: 10,
      target_charge_pct: 80, electricity_rate_per_kwh: 0.13,
      charger_type: "dc_fast"
    ).call
    assert level2[:valid] && dc_fast[:valid]
    assert dc_fast[:charge_time_hours] < level2[:charge_time_hours]
  end

  # --- Validation errors ---

  test "zero battery returns error" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 0, electricity_rate_per_kwh: 0.13
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Battery capacity must be positive"
  end

  test "target less than current returns error" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, current_charge_pct: 80,
      target_charge_pct: 50, electricity_rate_per_kwh: 0.13
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Target charge must be greater than current charge"
  end

  test "zero electricity rate returns error" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, electricity_rate_per_kwh: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Electricity rate must be positive"
  end

  test "invalid charger type returns error" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: 75, electricity_rate_per_kwh: 0.13,
      charger_type: "mega_charger"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Charger type must be level1, level2, dc_fast, or supercharger"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::EvChargingCostCalculator.new(
      battery_capacity_kwh: "75", current_charge_pct: "10",
      target_charge_pct: "80", electricity_rate_per_kwh: "0.13"
    ).call
    assert result[:valid]
  end
end
