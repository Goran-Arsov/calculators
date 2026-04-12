require "test_helper"

class Math::BaseArithmeticCalculatorTest < ActiveSupport::TestCase
  # --- Binary (base 2) ---

  test "binary addition: 1010 + 0110 = 10000" do
    result = Math::BaseArithmeticCalculator.new(number1: "1010", number2: "0110", base: 2, operation: "add").call
    assert result[:valid]
    assert_equal "10000", result[:result]
    assert_equal 16, result[:result_decimal]
  end

  test "binary subtraction: 1010 - 0011 = 111" do
    result = Math::BaseArithmeticCalculator.new(number1: "1010", number2: "11", base: 2, operation: "subtract").call
    assert result[:valid]
    assert_equal "111", result[:result]
    assert_equal 7, result[:result_decimal]
  end

  test "binary multiplication: 101 * 11 = 1111" do
    result = Math::BaseArithmeticCalculator.new(number1: "101", number2: "11", base: 2, operation: "multiply").call
    assert result[:valid]
    assert_equal "1111", result[:result]
    assert_equal 15, result[:result_decimal]
  end

  # --- Octal (base 8) ---

  test "octal addition: 17 + 5 = 24" do
    result = Math::BaseArithmeticCalculator.new(number1: "17", number2: "5", base: 8, operation: "add").call
    assert result[:valid]
    assert_equal "24", result[:result]
    assert_equal 20, result[:result_decimal]
  end

  # --- Hexadecimal (base 16) ---

  test "hex addition: FF + 1 = 100" do
    result = Math::BaseArithmeticCalculator.new(number1: "FF", number2: "1", base: 16, operation: "add").call
    assert result[:valid]
    assert_equal "100", result[:result]
    assert_equal 256, result[:result_decimal]
  end

  test "hex multiplication: A * B = 6E" do
    result = Math::BaseArithmeticCalculator.new(number1: "A", number2: "B", base: 16, operation: "multiply").call
    assert result[:valid]
    assert_equal "6E", result[:result]
    assert_equal 110, result[:result_decimal]
  end

  # --- Decimal (base 10) ---

  test "decimal addition works normally" do
    result = Math::BaseArithmeticCalculator.new(number1: "25", number2: "37", base: 10, operation: "add").call
    assert result[:valid]
    assert_equal "62", result[:result]
    assert_equal 62, result[:result_decimal]
  end

  # --- Zero result ---

  test "subtraction resulting in zero" do
    result = Math::BaseArithmeticCalculator.new(number1: "1010", number2: "1010", base: 2, operation: "subtract").call
    assert result[:valid]
    assert_equal "0", result[:result]
  end

  # --- Base names ---

  test "base 2 has name Binary" do
    result = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 2, operation: "add").call
    assert result[:valid]
    assert_equal "Binary", result[:base_name]
  end

  test "base 16 has name Hexadecimal" do
    result = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 16, operation: "add").call
    assert result[:valid]
    assert_equal "Hexadecimal", result[:base_name]
  end

  # --- Validation ---

  test "invalid digit for base returns error" do
    result = Math::BaseArithmeticCalculator.new(number1: "123", number2: "1", base: 2, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("invalid digit") }
  end

  test "base below 2 returns error" do
    result = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 1, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Base must be") }
  end

  test "base above 36 returns error" do
    result = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 37, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Base must be") }
  end

  test "unsupported operation returns error" do
    result = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 10, operation: "divide").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported operation") }
  end

  test "blank number returns error" do
    result = Math::BaseArithmeticCalculator.new(number1: "", number2: "1", base: 10, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("blank") }
  end

  test "errors accessor returns empty array before call" do
    calc = Math::BaseArithmeticCalculator.new(number1: "1", number2: "1", base: 10, operation: "add")
    assert_equal [], calc.errors
  end
end
