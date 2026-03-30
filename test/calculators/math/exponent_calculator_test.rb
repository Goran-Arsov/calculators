require "test_helper"

class Math::ExponentCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: 2 raised to 10 = 1024" do
    result = Math::ExponentCalculator.new(base: 2, exponent: 10).call
    assert result[:valid]
    assert_equal 1024.0, result[:result]
    assert_equal 2.0, result[:base]
    assert_equal 10.0, result[:exponent]
  end

  test "any base raised to 0 = 1" do
    result = Math::ExponentCalculator.new(base: 99, exponent: 0).call
    assert result[:valid]
    assert_equal 1.0, result[:result]
  end

  test "any base raised to 1 = itself" do
    result = Math::ExponentCalculator.new(base: 42, exponent: 1).call
    assert result[:valid]
    assert_equal 42.0, result[:result]
  end

  test "1 raised to any power = 1" do
    result = Math::ExponentCalculator.new(base: 1, exponent: 1000).call
    assert result[:valid]
    assert_equal 1.0, result[:result]
  end

  test "10 raised to 6 = 1000000" do
    result = Math::ExponentCalculator.new(base: 10, exponent: 6).call
    assert result[:valid]
    assert_equal 1_000_000.0, result[:result]
  end

  # --- Fractional exponents ---

  test "square root: 9^0.5 = 3" do
    result = Math::ExponentCalculator.new(base: 9, exponent: 0.5).call
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 0.0001
  end

  test "cube root: 27^(1/3) = 3" do
    result = Math::ExponentCalculator.new(base: 27, exponent: 1.0 / 3).call
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 0.0001
  end

  # --- Negative exponents ---

  test "positive base with negative exponent" do
    # 2^(-3) = 0.125
    result = Math::ExponentCalculator.new(base: 2, exponent: -3).call
    assert result[:valid]
    assert_in_delta 0.125, result[:result], 0.0001
  end

  test "negative base with even integer exponent is positive" do
    # (-3)^2 = 9
    result = Math::ExponentCalculator.new(base: -3, exponent: 2).call
    assert result[:valid]
    assert_equal 9.0, result[:result]
  end

  test "negative base with odd integer exponent is negative" do
    # (-2)^3 = -8
    result = Math::ExponentCalculator.new(base: -2, exponent: 3).call
    assert result[:valid]
    assert_equal(-8.0, result[:result])
  end

  # --- Zero base ---

  test "zero raised to positive power = 0" do
    result = Math::ExponentCalculator.new(base: 0, exponent: 5).call
    assert result[:valid]
    assert_equal 0.0, result[:result]
  end

  test "zero raised to zero = 1" do
    result = Math::ExponentCalculator.new(base: 0, exponent: 0).call
    assert result[:valid]
    assert_equal 1.0, result[:result]
  end

  test "zero raised to negative power returns error" do
    result = Math::ExponentCalculator.new(base: 0, exponent: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Cannot raise zero to a negative power"
  end

  # --- Edge cases: negative base with fractional exponent ---

  test "negative base with fractional exponent returns error" do
    result = Math::ExponentCalculator.new(base: -4, exponent: 0.5).call
    refute result[:valid]
    assert_includes result[:errors], "Cannot raise negative number to fractional power"
  end

  test "negative base with non-integer exponent returns error" do
    result = Math::ExponentCalculator.new(base: -2, exponent: 1.5).call
    refute result[:valid]
    assert_includes result[:errors], "Cannot raise negative number to fractional power"
  end

  # --- Very large numbers ---

  test "very large result is still valid" do
    result = Math::ExponentCalculator.new(base: 10, exponent: 100).call
    assert result[:valid]
    assert_in_delta 1e100, result[:result], 1e90
  end

  test "result too large returns error" do
    # This should overflow to infinity
    result = Math::ExponentCalculator.new(base: 10, exponent: 1000).call
    refute result[:valid]
    assert_includes result[:errors], "Result is too large or undefined"
  end

  # --- Very small result ---

  test "very small positive result" do
    result = Math::ExponentCalculator.new(base: 10, exponent: -100).call
    assert result[:valid]
    assert_in_delta 1e-100, result[:result], 1e-110
  end

  # --- Negative base with negative integer exponent ---

  test "negative base with negative integer exponent" do
    # (-2)^(-2) = 1/4 = 0.25
    result = Math::ExponentCalculator.new(base: -2, exponent: -2).call
    assert result[:valid]
    assert_in_delta 0.25, result[:result], 0.0001
  end

  test "errors accessor returns empty array before call" do
    calc = Math::ExponentCalculator.new(base: 2, exponent: 3)
    assert_equal [], calc.errors
  end
end
