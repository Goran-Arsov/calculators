require "test_helper"

class Everyday::VolumeConverterCalculatorTest < ActiveSupport::TestCase
  test "1 cubic meter to cubic feet" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_meter").call
    assert result[:valid]
    assert_in_delta 35.3147, result[:conversions][:cubic_foot], 0.01
  end

  test "1 cubic foot to cubic meters" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 0.0283168, result[:conversions][:cubic_meter], 0.0001
  end

  test "1 cubic yard to cubic feet" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_yard").call
    assert result[:valid]
    assert_in_delta 27.0, result[:conversions][:cubic_foot], 0.01
  end

  test "1 cubic meter to liters" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_meter").call
    assert result[:valid]
    assert_in_delta 1000.0, result[:conversions][:liter], 0.01
  end

  test "1 cubic foot to liters" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 28.3168, result[:conversions][:liter], 0.01
  end

  test "1 cubic foot to US gallons" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 7.4805, result[:conversions][:gallon_us], 0.01
  end

  test "1 cubic foot to UK gallons" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 6.2288, result[:conversions][:gallon_uk], 0.01
  end

  test "1 US gallon to liters" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "gallon_us").call
    assert result[:valid]
    assert_in_delta 3.78541, result[:conversions][:liter], 0.001
  end

  test "1 UK gallon to liters" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "gallon_uk").call
    assert result[:valid]
    assert_in_delta 4.54609, result[:conversions][:liter], 0.001
  end

  test "returns all units" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_meter").call
    assert result[:valid]
    assert_equal 7, result[:conversions].keys.length
    assert result[:conversions].key?(:cubic_meter)
    assert result[:conversions].key?(:cubic_foot)
    assert result[:conversions].key?(:cubic_inch)
    assert result[:conversions].key?(:cubic_yard)
    assert result[:conversions].key?(:liter)
    assert result[:conversions].key?(:gallon_us)
    assert result[:conversions].key?(:gallon_uk)
  end

  test "identity conversion" do
    result = Everyday::VolumeConverterCalculator.new(value: 42, from_unit: "cubic_meter").call
    assert result[:valid]
    assert_in_delta 42.0, result[:conversions][:cubic_meter], 0.0001
  end

  test "error for unknown unit" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cups").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "large value" do
    result = Everyday::VolumeConverterCalculator.new(value: 1000, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 28.3168, result[:conversions][:cubic_meter], 0.01
  end

  test "cubic inches conversion" do
    result = Everyday::VolumeConverterCalculator.new(value: 1, from_unit: "cubic_foot").call
    assert result[:valid]
    assert_in_delta 1728.0, result[:conversions][:cubic_inch], 1
  end
end
