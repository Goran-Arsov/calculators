require "test_helper"

class Physics::PressureConverterCalculatorTest < ActiveSupport::TestCase
  test "1 atm converts to standard values" do
    result = Physics::PressureConverterCalculator.new(value: 1, from_unit: "atm").call
    assert result[:valid]
    assert_in_delta 101_325.0, result[:conversions]["pa"][:value], 1.0
    assert_in_delta 101.325, result[:conversions]["kpa"][:value], 0.01
    assert_in_delta 1.01325, result[:conversions]["bar"][:value], 0.0001
    assert_in_delta 14.696, result[:conversions]["psi"][:value], 0.01
    assert_in_delta 760.0, result[:conversions]["mmhg"][:value], 0.5
    assert_in_delta 760.0, result[:conversions]["torr"][:value], 0.5
  end

  test "100000 Pa equals 1 bar" do
    result = Physics::PressureConverterCalculator.new(value: 100_000, from_unit: "pa").call
    assert result[:valid]
    assert_in_delta 1.0, result[:conversions]["bar"][:value], 0.0001
  end

  test "14.696 psi equals approximately 1 atm" do
    result = Physics::PressureConverterCalculator.new(value: 14.696, from_unit: "psi").call
    assert result[:valid]
    assert_in_delta 1.0, result[:conversions]["atm"][:value], 0.001
  end

  test "760 mmHg equals approximately 1 atm" do
    result = Physics::PressureConverterCalculator.new(value: 760, from_unit: "mmhg").call
    assert result[:valid]
    assert_in_delta 1.0, result[:conversions]["atm"][:value], 0.001
  end

  test "1 bar converts to psi" do
    result = Physics::PressureConverterCalculator.new(value: 1, from_unit: "bar").call
    assert result[:valid]
    assert_in_delta 14.5038, result[:conversions]["psi"][:value], 0.01
  end

  test "zero value converts to all zeros" do
    result = Physics::PressureConverterCalculator.new(value: 0, from_unit: "pa").call
    assert result[:valid]
    assert_in_delta 0.0, result[:conversions]["bar"][:value], 0.0001
    assert_in_delta 0.0, result[:conversions]["psi"][:value], 0.0001
    assert_in_delta 0.0, result[:conversions]["atm"][:value], 0.0001
  end

  test "negative pressure value is allowed" do
    result = Physics::PressureConverterCalculator.new(value: -101325, from_unit: "pa").call
    assert result[:valid]
    assert_in_delta(-1.0, result[:conversions]["atm"][:value], 0.001)
  end

  test "very large value" do
    result = Physics::PressureConverterCalculator.new(value: 1_000_000, from_unit: "psi").call
    assert result[:valid]
    assert result[:conversions]["pa"][:value] > 6_000_000_000
  end

  test "1 kPa equals 1000 Pa" do
    result = Physics::PressureConverterCalculator.new(value: 1, from_unit: "kpa").call
    assert result[:valid]
    assert_in_delta 1000.0, result[:conversions]["pa"][:value], 0.01
  end

  test "unknown unit returns error" do
    result = Physics::PressureConverterCalculator.new(value: 100, from_unit: "invalid").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown pressure unit") }
  end

  test "string coercion for value" do
    result = Physics::PressureConverterCalculator.new(value: "101325", from_unit: "pa").call
    assert result[:valid]
    assert_in_delta 1.0, result[:conversions]["atm"][:value], 0.001
  end

  test "result includes from_unit metadata" do
    result = Physics::PressureConverterCalculator.new(value: 1, from_unit: "atm").call
    assert result[:valid]
    assert_equal "atm", result[:from_unit]
    assert_equal "Atmosphere", result[:from_unit_name]
  end

  test "errors accessor starts empty" do
    calc = Physics::PressureConverterCalculator.new(value: 1, from_unit: "atm")
    assert_equal [], calc.errors
  end
end
