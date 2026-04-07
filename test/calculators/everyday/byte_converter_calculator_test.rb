require "test_helper"

class Everyday::ByteConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "1 GB converts to 1024 MiB binary" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "GB").call
    assert_equal true, result[:valid]
    assert_in_delta 1024.0, result[:binary][:MiB], 0.01
    assert_in_delta 1.0, result[:binary][:GiB], 0.001
  end

  test "1 GB binary shows correct decimal values" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "GB").call
    assert_equal true, result[:valid]
    # 1 GB (binary) = 1024^3 bytes = 1,073,741,824 bytes
    # In decimal GB: 1,073,741,824 / 1,000,000,000 = 1.073741824
    assert_in_delta 1.073742, result[:decimal][:GB], 0.001
  end

  test "1 KB converts to 1024 bytes" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "KB").call
    assert_equal true, result[:valid]
    assert_in_delta 1024.0, result[:binary][:B], 0.01
  end

  test "1 MB converts to 1024 KiB" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "MB").call
    assert_equal true, result[:valid]
    assert_in_delta 1024.0, result[:binary][:KiB], 0.01
  end

  test "1 TB converts correctly" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "TB").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:binary][:TiB], 0.001
    assert_in_delta 1024.0, result[:binary][:GiB], 0.01
  end

  test "1 PB converts correctly" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "PB").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:binary][:PiB], 0.001
    assert_in_delta 1024.0, result[:binary][:TiB], 0.01
  end

  test "1024 bytes converts to 1 KiB" do
    result = Everyday::ByteConverterCalculator.new(value: 1024, from_unit: "B").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:binary][:KiB], 0.001
  end

  test "zero value" do
    result = Everyday::ByteConverterCalculator.new(value: 0, from_unit: "B").call
    assert_equal true, result[:valid]
    assert_in_delta 0.0, result[:binary][:B], 0.001
    assert_in_delta 0.0, result[:decimal][:B], 0.001
  end

  test "string coercion for value" do
    result = Everyday::ByteConverterCalculator.new(value: "1024", from_unit: "B").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:binary][:KiB], 0.001
  end

  test "unit is case-insensitive" do
    result = Everyday::ByteConverterCalculator.new(value: 1, from_unit: "gb").call
    assert_equal true, result[:valid]
    assert_in_delta 1.0, result[:binary][:GiB], 0.001
  end

  test "very large value" do
    result = Everyday::ByteConverterCalculator.new(value: 1000, from_unit: "PB").call
    assert_equal true, result[:valid]
    assert result[:binary][:B] > 0
  end

  # --- Validation errors ---

  test "error for negative value" do
    result = Everyday::ByteConverterCalculator.new(value: -1, from_unit: "GB").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("zero or greater") }
  end

  test "error for unknown unit" do
    result = Everyday::ByteConverterCalculator.new(value: 10, from_unit: "EB").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown unit") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ByteConverterCalculator.new(value: 10, from_unit: "GB")
    assert_equal [], calc.errors
  end
end
