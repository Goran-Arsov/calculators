require "test_helper"

class Math::QuadraticCalculatorTest < ActiveSupport::TestCase
  # --- Two real roots ---

  test "two distinct real roots: x^2 - 5x + 6 = 0" do
    result = Math::QuadraticCalculator.new(a: 1, b: -5, c: 6).call
    assert result[:valid]
    assert_equal "real", result[:roots_type]
    assert_equal 3.0, result[:x1]
    assert_equal 2.0, result[:x2]
    assert_equal 1.0, result[:discriminant]
  end

  test "two distinct real roots: x^2 - 3x + 2 = 0" do
    result = Math::QuadraticCalculator.new(a: 1, b: -3, c: 2).call
    assert result[:valid]
    assert_equal 2.0, result[:x1]
    assert_equal 1.0, result[:x2]
  end

  test "vertex is calculated correctly" do
    result = Math::QuadraticCalculator.new(a: 1, b: -4, c: 3).call
    assert result[:valid]
    assert_equal 2.0, result[:vertex_x]
    assert_equal(-1.0, result[:vertex_y])
  end

  # --- Repeated root ---

  test "repeated root: x^2 - 6x + 9 = 0" do
    result = Math::QuadraticCalculator.new(a: 1, b: -6, c: 9).call
    assert result[:valid]
    assert_equal "repeated", result[:roots_type]
    assert_equal 3.0, result[:x1]
    assert_equal 3.0, result[:x2]
    assert_equal 0.0, result[:discriminant]
  end

  # --- Complex roots ---

  test "complex roots: x^2 + 1 = 0" do
    result = Math::QuadraticCalculator.new(a: 1, b: 0, c: 1).call
    assert result[:valid]
    assert_equal "complex", result[:roots_type]
    assert_match(/0\.0 \+ 1\.0i/, result[:x1])
    assert_match(/0\.0 - 1\.0i/, result[:x2])
    assert_equal(-4.0, result[:discriminant])
  end

  test "complex roots: x^2 + x + 1 = 0" do
    result = Math::QuadraticCalculator.new(a: 1, b: 1, c: 1).call
    assert result[:valid]
    assert_equal "complex", result[:roots_type]
    assert result[:x1].is_a?(String)
    assert result[:x2].is_a?(String)
  end

  # --- Negative leading coefficient ---

  test "negative a coefficient: -x^2 + 4 = 0" do
    result = Math::QuadraticCalculator.new(a: -1, b: 0, c: 4).call
    assert result[:valid]
    assert_equal "real", result[:roots_type]
    assert_equal(-2.0, result[:x1])
    assert_equal 2.0, result[:x2]
  end

  # --- Discriminant ---

  test "discriminant is returned in result" do
    result = Math::QuadraticCalculator.new(a: 2, b: 5, c: -3).call
    assert result[:valid]
    # discriminant = 25 - 4*2*(-3) = 25 + 24 = 49
    assert_equal 49.0, result[:discriminant]
  end

  # --- Validation errors ---

  test "error when a is zero" do
    result = Math::QuadraticCalculator.new(a: 0, b: 2, c: 1).call
    refute result[:valid]
    assert_includes result[:errors], "Coefficient a cannot be zero (not a quadratic equation)"
  end

  # --- Edge cases ---

  test "very large coefficients" do
    result = Math::QuadraticCalculator.new(a: 1, b: 0, c: -1_000_000).call
    assert result[:valid]
    assert_equal "real", result[:roots_type]
    assert_in_delta 1000.0, result[:x1], 0.01
  end

  test "fractional coefficients" do
    result = Math::QuadraticCalculator.new(a: 0.5, b: -1.5, c: 1).call
    assert result[:valid]
    assert_equal "real", result[:roots_type]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::QuadraticCalculator.new(a: 1, b: 2, c: 3)
    assert_equal [], calc.errors
  end
end
