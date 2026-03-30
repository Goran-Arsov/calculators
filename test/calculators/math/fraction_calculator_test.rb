require "test_helper"

class Math::FractionCalculatorTest < ActiveSupport::TestCase
  # --- Addition ---

  test "happy path: add 1/2 + 1/3 = 5/6" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 3, operation: "add").call
    assert result[:valid]
    assert_equal 5, result[:numerator]
    assert_equal 6, result[:denominator]
    assert_in_delta(5.0 / 6, result[:decimal], 0.000001)
  end

  test "add: simplifies result" do
    # 2/4 + 2/4 = 4/4 = 1/1
    result = Math::FractionCalculator.new(num1: 2, den1: 4, num2: 2, den2: 4, operation: "add").call
    assert result[:valid]
    assert_equal 1, result[:numerator]
    assert_equal 1, result[:denominator]
  end

  test "add: result with zero numerator" do
    # 1/2 + (-1/2) = 0/1
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: -1, den2: 2, operation: "add").call
    assert result[:valid]
    assert_equal 0, result[:numerator]
    assert_equal 0.0, result[:decimal]
  end

  test "add: negative fractions" do
    # -1/3 + -1/3 = -2/3
    result = Math::FractionCalculator.new(num1: -1, den1: 3, num2: -1, den2: 3, operation: "add").call
    assert result[:valid]
    assert_equal(-2, result[:numerator])
    assert_equal 3, result[:denominator]
  end

  test "add: very large numbers" do
    result = Math::FractionCalculator.new(num1: 999_999, den1: 1_000_000, num2: 1, den2: 1_000_000, operation: "add").call
    assert result[:valid]
    assert_equal 1, result[:numerator]
    assert_equal 1, result[:denominator]
  end

  # --- Subtraction ---

  test "happy path: subtract 3/4 - 1/4 = 1/2" do
    result = Math::FractionCalculator.new(num1: 3, den1: 4, num2: 1, den2: 4, operation: "subtract").call
    assert result[:valid]
    assert_equal 1, result[:numerator]
    assert_equal 2, result[:denominator]
  end

  test "subtract: result is negative" do
    # 1/4 - 3/4 = -1/2
    result = Math::FractionCalculator.new(num1: 1, den1: 4, num2: 3, den2: 4, operation: "subtract").call
    assert result[:valid]
    assert_equal(-1, result[:numerator])
    assert_equal 2, result[:denominator]
  end

  test "subtract: equal fractions give zero" do
    result = Math::FractionCalculator.new(num1: 5, den1: 7, num2: 5, den2: 7, operation: "subtract").call
    assert result[:valid]
    assert_equal 0, result[:numerator]
  end

  # --- Multiplication ---

  test "happy path: multiply 2/3 * 3/4 = 1/2" do
    result = Math::FractionCalculator.new(num1: 2, den1: 3, num2: 3, den2: 4, operation: "multiply").call
    assert result[:valid]
    assert_equal 1, result[:numerator]
    assert_equal 2, result[:denominator]
  end

  test "multiply: by zero numerator gives zero" do
    result = Math::FractionCalculator.new(num1: 0, den1: 5, num2: 3, den2: 4, operation: "multiply").call
    assert result[:valid]
    assert_equal 0, result[:numerator]
  end

  test "multiply: negative times negative is positive" do
    result = Math::FractionCalculator.new(num1: -1, den1: 2, num2: -1, den2: 3, operation: "multiply").call
    assert result[:valid]
    assert_equal 1, result[:numerator]
    assert_equal 6, result[:denominator]
  end

  # --- Division ---

  test "happy path: divide 1/2 by 1/4 = 2/1" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 4, operation: "divide").call
    assert result[:valid]
    assert_equal 2, result[:numerator]
    assert_equal 1, result[:denominator]
  end

  test "divide: by zero numerator returns error" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 0, den2: 3, operation: "divide").call
    refute result[:valid]
    assert_includes result[:errors], "Cannot divide by zero"
  end

  test "divide: negative fraction" do
    # (1/2) / (-1/3) = 1*3 / 2*(-1) = 3/-2 => -3/2
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: -1, den2: 3, operation: "divide").call
    assert result[:valid]
    assert_equal(-3, result[:numerator])
    assert_equal 2, result[:denominator]
  end

  # --- Negative sign normalization ---

  test "negative denominator is normalized to negative numerator" do
    # Denominator should always be positive in the result.
    # 1/(-2) + 0/1 = -1/2
    result = Math::FractionCalculator.new(num1: 1, den1: -2, num2: 0, den2: 1, operation: "add").call
    # den1=-2 triggers validation error since den1.to_i = -2 != 0 but...
    # Actually, the validation checks if den1.zero? which is false for -2, so it passes.
    # Result: num=1*1 + 0*(-2) = 1, den=(-2)*1 = -2, gcd(1,-2)=1
    # simplified: 1/-2, then since den<0 => -1/2
    assert result[:valid]
    assert_equal(-1, result[:numerator])
    assert_equal 2, result[:denominator]
  end

  # --- Validation errors ---

  test "first denominator zero returns error" do
    result = Math::FractionCalculator.new(num1: 1, den1: 0, num2: 1, den2: 2, operation: "add").call
    refute result[:valid]
    assert_includes result[:errors], "First denominator cannot be zero"
  end

  test "second denominator zero returns error" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 0, operation: "add").call
    refute result[:valid]
    assert_includes result[:errors], "Second denominator cannot be zero"
  end

  test "both denominators zero returns both errors" do
    result = Math::FractionCalculator.new(num1: 1, den1: 0, num2: 1, den2: 0, operation: "add").call
    refute result[:valid]
    assert_includes result[:errors], "First denominator cannot be zero"
    assert_includes result[:errors], "Second denominator cannot be zero"
  end

  test "invalid operation returns error" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 3, operation: "modulo").call
    refute result[:valid]
    assert_includes result[:errors], "Invalid operation"
  end

  test "operation is stored in result" do
    result = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 3, operation: "add").call
    assert_equal "add", result[:operation]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::FractionCalculator.new(num1: 1, den1: 2, num2: 1, den2: 3, operation: "add")
    assert_equal [], calc.errors
  end
end
