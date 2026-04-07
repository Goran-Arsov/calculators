require "test_helper"

class Everyday::TemperatureConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "0 celsius converts to 32 fahrenheit and 273.15 kelvin" do
    result = Everyday::TemperatureConverterCalculator.new(value: 0, from_unit: "celsius").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:celsius], 0.001
    assert_in_delta 32.0, result[:fahrenheit], 0.001
    assert_in_delta 273.15, result[:kelvin], 0.001
  end

  test "100 celsius converts to 212 fahrenheit and 373.15 kelvin" do
    result = Everyday::TemperatureConverterCalculator.new(value: 100, from_unit: "celsius").call
    assert_equal true, result[:valid]
    assert_in_delta 100.0, result[:celsius], 0.001
    assert_in_delta 212.0, result[:fahrenheit], 0.001
    assert_in_delta 373.15, result[:kelvin], 0.001
  end

  test "32 fahrenheit converts to 0 celsius" do
    result = Everyday::TemperatureConverterCalculator.new(value: 32, from_unit: "fahrenheit").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:celsius], 0.001
    assert_in_delta 32.0, result[:fahrenheit], 0.001
    assert_in_delta 273.15, result[:kelvin], 0.001
  end

  test "212 fahrenheit converts to 100 celsius" do
    result = Everyday::TemperatureConverterCalculator.new(value: 212, from_unit: "fahrenheit").call
    assert_equal true, result[:valid]
    assert_in_delta 100.0, result[:celsius], 0.001
  end

  test "273.15 kelvin converts to 0 celsius" do
    result = Everyday::TemperatureConverterCalculator.new(value: 273.15, from_unit: "kelvin").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:celsius], 0.001
    assert_in_delta 32.0, result[:fahrenheit], 0.001
  end

  test "0 kelvin converts to -273.15 celsius" do
    result = Everyday::TemperatureConverterCalculator.new(value: 0, from_unit: "kelvin").call
    assert_equal true, result[:valid]
    assert_in_delta(-273.15, result[:celsius], 0.001)
    assert_in_delta(-459.67, result[:fahrenheit], 0.01)
  end

  test "negative celsius value" do
    result = Everyday::TemperatureConverterCalculator.new(value: -40, from_unit: "celsius").call
    assert_equal true, result[:valid]
    assert_in_delta(-40.0, result[:fahrenheit], 0.001)
    assert_in_delta 233.15, result[:kelvin], 0.001
  end

  test "-40 fahrenheit equals -40 celsius" do
    result = Everyday::TemperatureConverterCalculator.new(value: -40, from_unit: "fahrenheit").call
    assert_equal true, result[:valid]
    assert_in_delta(-40.0, result[:celsius], 0.001)
  end

  test "string coercion for value" do
    result = Everyday::TemperatureConverterCalculator.new(value: "100", from_unit: "celsius").call
    assert_equal true, result[:valid]
    assert_in_delta 212.0, result[:fahrenheit], 0.001
  end

  test "returns original value and from_unit" do
    result = Everyday::TemperatureConverterCalculator.new(value: 50, from_unit: "celsius").call
    assert_equal "celsius", result[:from_unit]
    assert_equal 50.0, result[:original_value]
  end

  # --- Validation errors ---

  test "error for unknown unit" do
    result = Everyday::TemperatureConverterCalculator.new(value: 10, from_unit: "rankine").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "unit is case-insensitive" do
    result = Everyday::TemperatureConverterCalculator.new(value: 100, from_unit: "CELSIUS").call
    assert_equal true, result[:valid]
    assert_in_delta 212.0, result[:fahrenheit], 0.001
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TemperatureConverterCalculator.new(value: 10, from_unit: "celsius")
    assert_equal [], calc.errors
  end

  test "very large value" do
    result = Everyday::TemperatureConverterCalculator.new(value: 1_000_000, from_unit: "celsius").call
    assert_equal true, result[:valid]
    assert_in_delta 1_000_000.0, result[:celsius], 0.001
  end

  test "zero value is valid" do
    result = Everyday::TemperatureConverterCalculator.new(value: 0, from_unit: "fahrenheit").call
    assert_equal true, result[:valid]
  end
end
