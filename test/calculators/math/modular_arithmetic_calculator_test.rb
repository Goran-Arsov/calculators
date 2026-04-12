require "test_helper"

class Math::ModularArithmeticCalculatorTest < ActiveSupport::TestCase
  # --- Modular addition ---

  test "modular addition: 7 + 5 mod 10 = 2" do
    result = Math::ModularArithmeticCalculator.new(a: 7, b: 5, modulus: 10, operation: "add").call
    assert result[:valid]
    assert_equal 2, result[:result]
  end

  test "modular addition: 3 + 4 mod 12 = 7" do
    result = Math::ModularArithmeticCalculator.new(a: 3, b: 4, modulus: 12, operation: "add").call
    assert result[:valid]
    assert_equal 7, result[:result]
  end

  # --- Modular subtraction ---

  test "modular subtraction: 3 - 7 mod 10 = 6" do
    result = Math::ModularArithmeticCalculator.new(a: 3, b: 7, modulus: 10, operation: "subtract").call
    assert result[:valid]
    assert_equal 6, result[:result]
  end

  test "modular subtraction: 5 - 2 mod 7 = 3" do
    result = Math::ModularArithmeticCalculator.new(a: 5, b: 2, modulus: 7, operation: "subtract").call
    assert result[:valid]
    assert_equal 3, result[:result]
  end

  # --- Modular multiplication ---

  test "modular multiplication: 6 * 7 mod 10 = 2" do
    result = Math::ModularArithmeticCalculator.new(a: 6, b: 7, modulus: 10, operation: "multiply").call
    assert result[:valid]
    assert_equal 2, result[:result]
  end

  # --- Modular exponentiation ---

  test "modular exponentiation: 2^10 mod 1000 = 24" do
    result = Math::ModularArithmeticCalculator.new(a: 2, b: 10, modulus: 1000, operation: "exponentiate").call
    assert result[:valid]
    assert_equal 24, result[:result]
  end

  test "modular exponentiation: 3^0 mod 7 = 1" do
    result = Math::ModularArithmeticCalculator.new(a: 3, b: 0, modulus: 7, operation: "exponentiate").call
    assert result[:valid]
    assert_equal 1, result[:result]
  end

  test "modular exponentiation: 5^3 mod 13 = 8" do
    # 5^3 = 125, 125 mod 13 = 8
    result = Math::ModularArithmeticCalculator.new(a: 5, b: 3, modulus: 13, operation: "exponentiate").call
    assert result[:valid]
    assert_equal 8, result[:result]
  end

  # --- Modular inverse ---

  test "modular inverse: 3^-1 mod 7 = 5" do
    # 3 * 5 = 15 ≡ 1 (mod 7)
    result = Math::ModularArithmeticCalculator.new(a: 3, modulus: 7, operation: "inverse").call
    assert result[:valid]
    assert_equal 5, result[:result]
    assert result[:exists]
  end

  test "modular inverse exists: verification" do
    result = Math::ModularArithmeticCalculator.new(a: 3, modulus: 7, operation: "inverse").call
    assert result[:valid]
    assert_equal 1, result[:verification]
  end

  test "no inverse when gcd != 1" do
    result = Math::ModularArithmeticCalculator.new(a: 6, modulus: 9, operation: "inverse").call
    assert result[:valid]
    refute result[:exists]
    assert_nil result[:result]
  end

  # --- Display format ---

  test "displays formatted result" do
    result = Math::ModularArithmeticCalculator.new(a: 7, b: 5, modulus: 10, operation: "add").call
    assert result[:valid]
    assert result[:display].is_a?(String)
    assert result[:display].length > 0
  end

  # --- Validation ---

  test "modulus of 1 returns error" do
    result = Math::ModularArithmeticCalculator.new(a: 5, b: 3, modulus: 1, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Modulus") }
  end

  test "modulus of 0 returns error" do
    result = Math::ModularArithmeticCalculator.new(a: 5, b: 3, modulus: 0, operation: "add").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Modulus") }
  end

  test "negative exponent returns error" do
    result = Math::ModularArithmeticCalculator.new(a: 5, b: -1, modulus: 7, operation: "exponentiate").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("non-negative") }
  end

  test "unsupported operation returns error" do
    result = Math::ModularArithmeticCalculator.new(a: 5, b: 3, modulus: 7, operation: "divide").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported operation") }
  end

  test "errors accessor returns empty array before call" do
    calc = Math::ModularArithmeticCalculator.new(a: 5, b: 3, modulus: 7, operation: "add")
    assert_equal [], calc.errors
  end
end
