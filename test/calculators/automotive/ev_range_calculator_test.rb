require "test_helper"

class Automotive::EvRangeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: ideal conditions ---

  test "happy path: 75 kWh battery at 250 Wh/mi = 300 mile base range" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 55, temperature_f: 70
    ).call
    assert result[:valid]
    assert_in_delta 300.0, result[:base_range_miles], 0.1
    assert_in_delta 300.0, result[:adjusted_range_miles], 5.0
    assert_in_delta 0.0, result[:range_loss_pct], 1.0
  end

  # --- Speed reduces range ---

  test "high speed reduces range" do
    slow = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 55, temperature_f: 70
    ).call
    fast = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 80, temperature_f: 70
    ).call
    assert slow[:valid] && fast[:valid]
    assert fast[:adjusted_range_miles] < slow[:adjusted_range_miles]
  end

  # --- Cold weather reduces range ---

  test "cold temperature reduces range" do
    warm = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 65, temperature_f: 70
    ).call
    cold = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 65, temperature_f: 20
    ).call
    assert warm[:valid] && cold[:valid]
    assert cold[:adjusted_range_miles] < warm[:adjusted_range_miles]
  end

  # --- HVAC reduces range ---

  test "HVAC on reduces range" do
    no_hvac = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 65, temperature_f: 70, hvac_on: false
    ).call
    hvac = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      speed_mph: 65, temperature_f: 70, hvac_on: true
    ).call
    assert no_hvac[:valid] && hvac[:valid]
    assert hvac[:adjusted_range_miles] < no_hvac[:adjusted_range_miles]
  end

  # --- Charge times ---

  test "charge times are positive" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250
    ).call
    assert result[:valid]
    assert result[:level2_charge_hours] > 0
    assert result[:dc_fast_charge_minutes] > 0
  end

  # --- Validation errors ---

  test "zero battery returns error" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 0, efficiency_wh_per_mile: 250
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Battery capacity must be positive"
  end

  test "zero efficiency returns error" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Efficiency must be positive"
  end

  test "negative cargo returns error" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: 75, efficiency_wh_per_mile: 250,
      cargo_weight_lbs: -100
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Cargo weight cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::EvRangeCalculator.new(
      battery_capacity_kwh: "75", efficiency_wh_per_mile: "250"
    ).call
    assert result[:valid]
  end
end
