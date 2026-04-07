require "test_helper"

class Everyday::WeightConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 kg converts correctly to all units" do
    result = Everyday::WeightConverterCalculator.new(value: 1, from_unit: "kg").call
    assert_equal true, result[:valid]
    assert_in_delta 1_000_000.0, result[:conversions][:mg], 1
    assert_in_delta 1000.0, result[:conversions][:g], 0.01
    assert_in_delta 1.0, result[:conversions][:kg], 0.001
    assert_in_delta 0.001, result[:conversions][:tonne], 0.0001
    assert_in_delta 35.274, result[:conversions][:ounce], 0.01
    assert_in_delta 2.20462, result[:conversions][:pound], 0.001
    assert_in_delta 0.157473, result[:conversions][:stone], 0.001
  end

  test "1 pound converts to 453.592 grams" do
    result = Everyday::WeightConverterCalculator.new(value: 1, from_unit: "pound").call
    assert_equal true, result[:valid]
    assert_in_delta 453.592, result[:conversions][:g], 0.01
  end

  test "1 ounce converts to 28.3495 grams" do
    result = Everyday::WeightConverterCalculator.new(value: 1, from_unit: "ounce").call
    assert_equal true, result[:valid]
    assert_in_delta 28.3495, result[:conversions][:g], 0.01
  end

  test "1 stone converts to 14 pounds" do
    result = Everyday::WeightConverterCalculator.new(value: 1, from_unit: "stone").call
    assert_equal true, result[:valid]
    assert_in_delta 14.0, result[:conversions][:pound], 0.01
  end

  test "1 tonne converts to 1000 kg" do
    result = Everyday::WeightConverterCalculator.new(value: 1, from_unit: "tonne").call
    assert_equal true, result[:valid]
    assert_in_delta 1000.0, result[:conversions][:kg], 0.01
  end

  test "string coercion for value" do
    result = Everyday::WeightConverterCalculator.new(value: "500", from_unit: "g").call
    assert_equal true, result[:valid]
    assert_in_delta 0.5, result[:conversions][:kg], 0.001
  end

  test "zero value" do
    result = Everyday::WeightConverterCalculator.new(value: 0, from_unit: "kg").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:conversions][:g], 0.001
  end

  test "very large value" do
    result = Everyday::WeightConverterCalculator.new(value: 1_000_000, from_unit: "mg").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:conversions][:kg], 0.001
  end

  # --- Validation errors ---

  test "error for unknown unit" do
    result = Everyday::WeightConverterCalculator.new(value: 10, from_unit: "carat").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::WeightConverterCalculator.new(value: 10, from_unit: "kg")
    assert_equal [], calc.errors
  end
end
