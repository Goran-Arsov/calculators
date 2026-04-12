require "test_helper"

class Physics::TransformerTurnsRatioCalculatorTest < ActiveSupport::TestCase
  test "find_output_voltage: step-down transformer" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_voltage", primary_voltage: 120, primary_turns: 500, secondary_turns: 100
    ).call
    assert result[:valid]
    # V2 = 120 * 100/500 = 24
    assert_in_delta 24.0, result[:secondary_voltage_v], 0.01
    assert_equal "Step-down", result[:transformer_type]
  end

  test "find_output_voltage: step-up transformer" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_voltage", primary_voltage: 120, primary_turns: 100, secondary_turns: 500
    ).call
    assert result[:valid]
    assert_in_delta 600.0, result[:secondary_voltage_v], 0.01
    assert_equal "Step-up", result[:transformer_type]
  end

  test "find_output_voltage: with current, computes power" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_voltage", primary_voltage: 120, primary_turns: 500,
      secondary_turns: 100, primary_current: 5
    ).call
    assert result[:valid]
    assert_in_delta 600.0, result[:primary_power_w], 0.01
    assert_in_delta 600.0, result[:secondary_power_w], 0.01
    assert_in_delta 25.0, result[:secondary_current_a], 0.01
  end

  test "find_output_current: ideal transformer" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_current", primary_voltage: 120, secondary_voltage: 24,
      primary_current: 5
    ).call
    assert result[:valid]
    # P1 = 600, P2 = 600 (100% eff), I2 = 600/24 = 25
    assert_in_delta 25.0, result[:secondary_current_a], 0.01
  end

  test "find_output_current: with efficiency loss" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_current", primary_voltage: 120, secondary_voltage: 24,
      primary_current: 5, efficiency: 95
    ).call
    assert result[:valid]
    # P1 = 600, P2 = 570, I2 = 570/24 = 23.75
    assert_in_delta 23.75, result[:secondary_current_a], 0.01
    assert_in_delta 95.0, result[:efficiency_percent], 0.01
  end

  test "find_turns_ratio: from voltages" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: 120, secondary_voltage: 24
    ).call
    assert result[:valid]
    assert_in_delta 5.0, result[:turns_ratio], 0.01
    assert_equal "5.0:1", result[:turns_ratio_display]
  end

  test "find_turns: secondary turns from voltages and primary turns" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns", primary_voltage: 120, secondary_voltage: 24, primary_turns: 500
    ).call
    assert result[:valid]
    assert_in_delta 100.0, result[:secondary_turns], 0.1
  end

  test "isolation transformer (1:1)" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: 120, secondary_voltage: 120
    ).call
    assert result[:valid]
    assert_equal "Isolation (1:1)", result[:transformer_type]
  end

  test "step-up ratio display" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: 24, secondary_voltage: 120
    ).call
    assert result[:valid]
    assert_equal "Step-up", result[:transformer_type]
    assert_equal "1:5.0", result[:turns_ratio_display]
  end

  test "zero primary voltage returns error" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: 0, secondary_voltage: 24
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Primary voltage must be a positive number"
  end

  test "missing secondary voltage for find_output_current returns error" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_output_current", primary_voltage: 120, primary_current: 5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Secondary voltage is required"
  end

  test "invalid mode returns error" do
    result = Physics::TransformerTurnsRatioCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "efficiency out of range returns error" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: 120, secondary_voltage: 24,
      efficiency: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Efficiency must be between 0 and 100 percent"
  end

  test "string coercion" do
    result = Physics::TransformerTurnsRatioCalculator.new(
      mode: "find_turns_ratio", primary_voltage: "120", secondary_voltage: "24"
    ).call
    assert result[:valid]
    assert_in_delta 5.0, result[:turns_ratio], 0.01
  end
end
