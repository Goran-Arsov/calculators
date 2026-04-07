require "test_helper"

class Everyday::SpeedConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 m/s converts correctly to all units" do
    result = Everyday::SpeedConverterCalculator.new(value: 1, from_unit: "m/s").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:conversions][:"m/s"], 0.001
    assert_in_delta 3.6, result[:conversions][:"km/h"], 0.001
    assert_in_delta 2.23694, result[:conversions][:mph], 0.001
    assert_in_delta 1.94384, result[:conversions][:knots], 0.001
    assert_in_delta 3.28084, result[:conversions][:"ft/s"], 0.001
  end

  test "100 km/h converts to m/s" do
    result = Everyday::SpeedConverterCalculator.new(value: 100, from_unit: "km/h").call
    assert_equal true, result[:valid]
    assert_in_delta 27.7778, result[:conversions][:"m/s"], 0.01
  end

  test "60 mph converts to km/h" do
    result = Everyday::SpeedConverterCalculator.new(value: 60, from_unit: "mph").call
    assert_equal true, result[:valid]
    assert_in_delta 96.5606, result[:conversions][:"km/h"], 0.01
  end

  test "1 knot converts to 1.852 km/h" do
    result = Everyday::SpeedConverterCalculator.new(value: 1, from_unit: "knots").call
    assert_equal true, result[:valid]
    assert_in_delta 1.852, result[:conversions][:"km/h"], 0.01
  end

  test "1 ft/s converts to 0.3048 m/s" do
    result = Everyday::SpeedConverterCalculator.new(value: 1, from_unit: "ft/s").call
    assert_equal true, result[:valid]
    assert_in_delta 0.3048, result[:conversions][:"m/s"], 0.001
  end

  test "string coercion for value" do
    result = Everyday::SpeedConverterCalculator.new(value: "100", from_unit: "km/h").call
    assert_equal true, result[:valid]
    assert_in_delta 27.7778, result[:conversions][:"m/s"], 0.01
  end

  test "zero value" do
    result = Everyday::SpeedConverterCalculator.new(value: 0, from_unit: "m/s").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:conversions][:"km/h"], 0.001
  end

  test "very large value" do
    result = Everyday::SpeedConverterCalculator.new(value: 299_792_458, from_unit: "m/s").call
    assert_equal true, result[:valid]
    assert result[:conversions][:"km/h"] > 1_000_000_000
  end

  # --- Validation errors ---

  test "error for unknown unit" do
    result = Everyday::SpeedConverterCalculator.new(value: 10, from_unit: "mach").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SpeedConverterCalculator.new(value: 10, from_unit: "m/s")
    assert_equal [], calc.errors
  end
end
