require "test_helper"

class Math::BaseConverterCalculatorTest < ActiveSupport::TestCase
  # --- Decimal input ---

  test "converts decimal 255 to all bases" do
    result = Math::BaseConverterCalculator.new(value: "255", input_base: "decimal").call
    assert result[:valid]
    assert_equal "255", result[:decimal]
    assert_equal "11111111", result[:binary]
    assert_equal "377", result[:octal]
    assert_equal "FF", result[:hex]
  end

  test "converts decimal 0 to all bases" do
    result = Math::BaseConverterCalculator.new(value: "0", input_base: "decimal").call
    assert result[:valid]
    assert_equal "0", result[:decimal]
    assert_equal "0", result[:binary]
    assert_equal "0", result[:octal]
    assert_equal "0", result[:hex]
  end

  test "converts decimal 42 to all bases" do
    result = Math::BaseConverterCalculator.new(value: "42", input_base: "decimal").call
    assert result[:valid]
    assert_equal "42", result[:decimal]
    assert_equal "101010", result[:binary]
    assert_equal "52", result[:octal]
    assert_equal "2A", result[:hex]
  end

  # --- Binary input ---

  test "converts binary 1010 to decimal 10" do
    result = Math::BaseConverterCalculator.new(value: "1010", input_base: "binary").call
    assert result[:valid]
    assert_equal "10", result[:decimal]
    assert_equal "1010", result[:binary]
  end

  test "converts binary 11111111 to decimal 255" do
    result = Math::BaseConverterCalculator.new(value: "11111111", input_base: "binary").call
    assert result[:valid]
    assert_equal "255", result[:decimal]
    assert_equal "FF", result[:hex]
  end

  # --- Hex input ---

  test "converts hex FF to decimal 255" do
    result = Math::BaseConverterCalculator.new(value: "FF", input_base: "hex").call
    assert result[:valid]
    assert_equal "255", result[:decimal]
    assert_equal "11111111", result[:binary]
  end

  test "converts hex 1A to decimal 26" do
    result = Math::BaseConverterCalculator.new(value: "1A", input_base: "hex").call
    assert result[:valid]
    assert_equal "26", result[:decimal]
  end

  # --- Octal input ---

  test "converts octal 77 to decimal 63" do
    result = Math::BaseConverterCalculator.new(value: "77", input_base: "octal").call
    assert result[:valid]
    assert_equal "63", result[:decimal]
    assert_equal "111111", result[:binary]
  end

  # --- Validation ---

  test "error for invalid binary digits" do
    result = Math::BaseConverterCalculator.new(value: "123", input_base: "binary").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("not valid") }
  end

  test "error for invalid octal digits" do
    result = Math::BaseConverterCalculator.new(value: "89", input_base: "octal").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("not valid") }
  end

  test "error for invalid hex digits" do
    result = Math::BaseConverterCalculator.new(value: "XYZ", input_base: "hex").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("not valid") }
  end

  test "error for empty value" do
    result = Math::BaseConverterCalculator.new(value: "", input_base: "decimal").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("required") }
  end

  test "error for invalid base" do
    result = Math::BaseConverterCalculator.new(value: "10", input_base: "ternary").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid input base") }
  end

  # --- Large numbers ---

  test "large decimal number" do
    result = Math::BaseConverterCalculator.new(value: "1000000", input_base: "decimal").call
    assert result[:valid]
    assert_equal "1000000", result[:decimal]
    assert_equal "11110100001001000000", result[:binary]
  end

  # --- Negative numbers ---

  test "negative decimal input" do
    result = Math::BaseConverterCalculator.new(value: "-10", input_base: "decimal").call
    assert result[:valid]
    assert_equal "-10", result[:decimal]
    assert_equal "-1010", result[:binary]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::BaseConverterCalculator.new(value: "10", input_base: "decimal")
    assert_equal [], calc.errors
  end
end
