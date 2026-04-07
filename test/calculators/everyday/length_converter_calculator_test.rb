require "test_helper"

class Everyday::LengthConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 meter converts correctly to all units" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "m").call
    assert_equal true, result[:valid]
    assert_in_delta 1000.0, result[:conversions][:mm], 0.01
    assert_in_delta 100.0, result[:conversions][:cm], 0.01
    assert_in_delta 1.0, result[:conversions][:m], 0.01
    assert_in_delta 0.001, result[:conversions][:km], 0.0001
    assert_in_delta 39.3701, result[:conversions][:inch], 0.01
    assert_in_delta 3.28084, result[:conversions][:foot], 0.001
    assert_in_delta 1.09361, result[:conversions][:yard], 0.001
    assert_in_delta 0.000621, result[:conversions][:mile], 0.0001
  end

  test "1 inch converts to 25.4 mm" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "inch").call
    assert_equal true, result[:valid]
    assert_in_delta 25.4, result[:conversions][:mm], 0.01
  end

  test "1 mile converts to 1.60934 km" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "mile").call
    assert_equal true, result[:valid]
    assert_in_delta 1.609344, result[:conversions][:km], 0.001
  end

  test "1 foot converts to 12 inches" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "foot").call
    assert_equal true, result[:valid]
    assert_in_delta 12.0, result[:conversions][:inch], 0.01
  end

  test "1 km converts to 1000 m" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "km").call
    assert_equal true, result[:valid]
    assert_in_delta 1000.0, result[:conversions][:m], 0.01
  end

  test "1 yard converts to 3 feet" do
    result = Everyday::LengthConverterCalculator.new(value: 1, from_unit: "yard").call
    assert_equal true, result[:valid]
    assert_in_delta 3.0, result[:conversions][:foot], 0.001
  end

  test "string coercion for value" do
    result = Everyday::LengthConverterCalculator.new(value: "100", from_unit: "cm").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:conversions][:m], 0.01
  end

  test "zero value" do
    result = Everyday::LengthConverterCalculator.new(value: 0, from_unit: "m").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:conversions][:km], 0.001
  end

  test "very large value" do
    result = Everyday::LengthConverterCalculator.new(value: 1_000_000, from_unit: "mm").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:conversions][:km], 0.001
  end

  # --- Validation errors ---

  test "error for unknown unit" do
    result = Everyday::LengthConverterCalculator.new(value: 10, from_unit: "furlong").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::LengthConverterCalculator.new(value: 10, from_unit: "m")
    assert_equal [], calc.errors
  end
end
