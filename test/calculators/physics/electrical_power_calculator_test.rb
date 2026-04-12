require "test_helper"

class Physics::ElectricalPowerCalculatorTest < ActiveSupport::TestCase
  test "p_iv: P = I * V" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_iv", current: 5, voltage: 120
    ).call
    assert result[:valid]
    assert_in_delta 600.0, result[:power_w], 0.01
  end

  test "p_i2r: P = I^2 * R" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_i2r", current: 5, resistance: 24
    ).call
    assert result[:valid]
    # P = 25 * 24 = 600
    assert_in_delta 600.0, result[:power_w], 0.01
    assert_in_delta 120.0, result[:voltage_v], 0.01
  end

  test "p_v2r: P = V^2 / R" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_v2r", voltage: 120, resistance: 24
    ).call
    assert result[:valid]
    # P = 14400 / 24 = 600
    assert_in_delta 600.0, result[:power_w], 0.01
    assert_in_delta 5.0, result[:current_a], 0.01
  end

  test "find_current: I = P / V" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "find_current", power: 600, voltage: 120
    ).call
    assert result[:valid]
    assert_in_delta 5.0, result[:current_a], 0.01
  end

  test "find_voltage: V = P / I" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "find_voltage", power: 600, current: 5
    ).call
    assert result[:valid]
    assert_in_delta 120.0, result[:voltage_v], 0.01
  end

  test "find_resistance: R = V^2 / P" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "find_resistance", power: 600, voltage: 120
    ).call
    assert result[:valid]
    assert_in_delta 24.0, result[:resistance_ohm], 0.01
  end

  test "power_kw is power / 1000" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_iv", current: 5, voltage: 120
    ).call
    assert result[:valid]
    assert_in_delta 0.6, result[:power_kw], 0.001
  end

  test "energy per hour in joules" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_iv", current: 5, voltage: 120
    ).call
    assert result[:valid]
    # 600W * 3600s = 2,160,000 J
    assert_in_delta 2_160_000.0, result[:energy_j_per_hour], 1.0
  end

  test "zero current in p_iv returns error" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_iv", current: 0, voltage: 120
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Current must be non-zero"
  end

  test "zero resistance returns error" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_i2r", current: 5, resistance: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Resistance must be a positive number"
  end

  test "missing voltage returns error" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "find_current", power: 600
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Voltage is required"
  end

  test "invalid mode returns error" do
    result = Physics::ElectricalPowerCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "string coercion" do
    result = Physics::ElectricalPowerCalculator.new(
      mode: "p_iv", current: "5", voltage: "120"
    ).call
    assert result[:valid]
    assert_in_delta 600.0, result[:power_w], 0.01
  end
end
