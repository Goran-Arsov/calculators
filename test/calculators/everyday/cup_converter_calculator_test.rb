require "test_helper"

class Everyday::CupConverterCalculatorTest < ActiveSupport::TestCase
  test "1 US cup to mL" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 236.588, result[:conversions][:ml], 0.01
  end

  test "1 metric cup to mL" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "metric_cup").call
    assert result[:valid]
    assert_in_delta 250.0, result[:conversions][:ml], 0.01
  end

  test "1 imperial cup to mL" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "imperial_cup").call
    assert result[:valid]
    assert_in_delta 284.131, result[:conversions][:ml], 0.01
  end

  test "236.588 mL to US cups" do
    result = Everyday::CupConverterCalculator.new(value: 236.588, from_unit: "ml").call
    assert result[:valid]
    assert_in_delta 1.0, result[:conversions][:us_cup], 0.001
  end

  test "1 US cup to fluid ounces" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 8.0, result[:conversions][:fl_oz], 0.01
  end

  test "1 US cup to tablespoons" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 16.0, result[:conversions][:us_tbsp], 0.1
  end

  test "1 US cup to teaspoons" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 48.0, result[:conversions][:us_tsp], 0.1
  end

  test "1 liter to mL" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "l").call
    assert result[:valid]
    assert_in_delta 1000.0, result[:conversions][:ml], 0.01
  end

  test "returns all units" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "us_cup").call
    assert result[:valid]
    assert_equal 8, result[:conversions].keys.length
    assert result[:conversions].key?(:us_cup)
    assert result[:conversions].key?(:metric_cup)
    assert result[:conversions].key?(:imperial_cup)
    assert result[:conversions].key?(:ml)
    assert result[:conversions].key?(:l)
    assert result[:conversions].key?(:fl_oz)
    assert result[:conversions].key?(:us_tbsp)
    assert result[:conversions].key?(:us_tsp)
  end

  test "identity conversion" do
    result = Everyday::CupConverterCalculator.new(value: 5, from_unit: "ml").call
    assert result[:valid]
    assert_in_delta 5.0, result[:conversions][:ml], 0.0001
  end

  test "error for unknown unit" do
    result = Everyday::CupConverterCalculator.new(value: 1, from_unit: "gallon").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "large value" do
    result = Everyday::CupConverterCalculator.new(value: 1000, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 236_588.0, result[:conversions][:ml], 1
  end

  test "fractional value" do
    result = Everyday::CupConverterCalculator.new(value: 0.25, from_unit: "us_cup").call
    assert result[:valid]
    assert_in_delta 59.147, result[:conversions][:ml], 0.1
  end
end
