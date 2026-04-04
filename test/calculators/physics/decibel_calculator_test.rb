require "test_helper"

class Physics::DecibelCalculatorTest < ActiveSupport::TestCase
  test "power ratio to dB: doubling" do
    result = Physics::DecibelCalculator.new(mode: "power_to_db", value: 2).call
    assert result[:valid]
    assert_in_delta 3.0103, result[:db], 0.001
  end

  test "power ratio to dB: 10x" do
    result = Physics::DecibelCalculator.new(mode: "power_to_db", value: 10).call
    assert result[:valid]
    assert_in_delta 10.0, result[:db], 0.001
  end

  test "dB to power ratio: 3 dB" do
    result = Physics::DecibelCalculator.new(mode: "db_to_power", value: 3).call
    assert result[:valid]
    assert_in_delta 1.9953, result[:ratio], 0.001
  end

  test "dB to power ratio: 10 dB" do
    result = Physics::DecibelCalculator.new(mode: "db_to_power", value: 10).call
    assert result[:valid]
    assert_in_delta 10.0, result[:ratio], 0.001
  end

  test "voltage ratio to dB: doubling" do
    result = Physics::DecibelCalculator.new(mode: "voltage_to_db", value: 2).call
    assert result[:valid]
    assert_in_delta 6.0206, result[:db], 0.001
  end

  test "dB to voltage ratio: 6 dB" do
    result = Physics::DecibelCalculator.new(mode: "db_to_voltage", value: 6).call
    assert result[:valid]
    assert_in_delta 1.9953, result[:ratio], 0.001
  end

  test "negative dB is valid for ratio conversions" do
    result = Physics::DecibelCalculator.new(mode: "db_to_power", value: -3).call
    assert result[:valid]
    assert_in_delta 0.5012, result[:ratio], 0.001
  end

  test "zero ratio for power_to_db returns error" do
    result = Physics::DecibelCalculator.new(mode: "power_to_db", value: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Ratio must be positive"
  end

  test "unknown mode returns error" do
    result = Physics::DecibelCalculator.new(mode: "invalid", value: 10).call
    refute result[:valid]
  end

  test "errors accessor" do
    calc = Physics::DecibelCalculator.new(mode: "power_to_db", value: 2)
    assert_equal [], calc.errors
  end
end
