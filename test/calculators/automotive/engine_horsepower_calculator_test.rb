require "test_helper"

class Automotive::EngineHorsepowerCalculatorTest < ActiveSupport::TestCase
  # --- HP from torque ---

  test "happy path: HP from torque at 5252 RPM equals torque" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 300, rpm: 5252, mode: "hp_from_torque"
    ).call
    assert result[:valid]
    assert_in_delta 300.0, result[:horsepower], 0.1
  end

  test "HP from torque: 350 lb-ft at 5500 RPM" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 350, rpm: 5500, mode: "hp_from_torque"
    ).call
    assert result[:valid]
    expected_hp = (350.0 * 5500.0) / 5252.0
    assert_in_delta expected_hp, result[:horsepower], 0.1
  end

  # --- Torque from HP ---

  test "torque from HP at 5252 RPM equals HP" do
    result = Automotive::EngineHorsepowerCalculator.new(
      horsepower: 300, rpm: 5252, mode: "torque_from_hp"
    ).call
    assert result[:valid]
    assert_in_delta 300.0, result[:torque_lb_ft], 0.1
  end

  test "torque from HP: 400 HP at 6000 RPM" do
    result = Automotive::EngineHorsepowerCalculator.new(
      horsepower: 400, rpm: 6000, mode: "torque_from_hp"
    ).call
    assert result[:valid]
    expected_torque = (400.0 * 5252.0) / 6000.0
    assert_in_delta expected_torque, result[:torque_lb_ft], 0.1
  end

  # --- Metric conversions ---

  test "kW conversion is correct" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 350, rpm: 5500, mode: "hp_from_torque"
    ).call
    assert result[:valid]
    assert_in_delta result[:horsepower] * 0.7457, result[:kilowatts], 0.1
  end

  test "Nm conversion is correct" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 350, rpm: 5500, mode: "hp_from_torque"
    ).call
    assert result[:valid]
    assert_in_delta 350.0 * 1.3558, result[:torque_nm], 0.1
  end

  # --- Validation errors ---

  test "zero torque returns error in hp_from_torque mode" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 0, rpm: 5000, mode: "hp_from_torque"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Torque must be positive"
  end

  test "zero RPM returns error" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 350, rpm: 0, mode: "hp_from_torque"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "RPM must be positive"
  end

  test "zero HP returns error in torque_from_hp mode" do
    result = Automotive::EngineHorsepowerCalculator.new(
      horsepower: 0, rpm: 5000, mode: "torque_from_hp"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Horsepower must be positive"
  end

  test "invalid mode returns error" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: 350, rpm: 5000, mode: "invalid"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be hp_from_torque or torque_from_hp"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::EngineHorsepowerCalculator.new(
      torque_lb_ft: "350", rpm: "5500", mode: "hp_from_torque"
    ).call
    assert result[:valid]
  end
end
