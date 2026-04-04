require "test_helper"

class Math::GcdLcmCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "GCD and LCM of 12 and 18" do
    result = Math::GcdLcmCalculator.new(a: 12, b: 18).call
    assert result[:valid]
    assert_equal 6, result[:gcd]
    assert_equal 36, result[:lcm]
  end

  test "GCD and LCM of 7 and 13 (coprime)" do
    result = Math::GcdLcmCalculator.new(a: 7, b: 13).call
    assert result[:valid]
    assert_equal 1, result[:gcd]
    assert_equal 91, result[:lcm]
  end

  test "GCD and LCM of equal numbers" do
    result = Math::GcdLcmCalculator.new(a: 15, b: 15).call
    assert result[:valid]
    assert_equal 15, result[:gcd]
    assert_equal 15, result[:lcm]
  end

  test "GCD and LCM where one divides the other" do
    result = Math::GcdLcmCalculator.new(a: 6, b: 24).call
    assert result[:valid]
    assert_equal 6, result[:gcd]
    assert_equal 24, result[:lcm]
  end

  test "returns a and b in result" do
    result = Math::GcdLcmCalculator.new(a: 10, b: 25).call
    assert result[:valid]
    assert_equal 10, result[:a]
    assert_equal 25, result[:b]
    assert_equal 5, result[:gcd]
    assert_equal 50, result[:lcm]
  end

  # --- Validation errors ---

  test "error when a is zero" do
    result = Math::GcdLcmCalculator.new(a: 0, b: 5).call
    refute result[:valid]
    assert_includes result[:errors], "First number must be a positive integer"
  end

  test "error when b is zero" do
    result = Math::GcdLcmCalculator.new(a: 5, b: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Second number must be a positive integer"
  end

  test "error when a is negative" do
    result = Math::GcdLcmCalculator.new(a: -5, b: 10).call
    refute result[:valid]
    assert_includes result[:errors], "First number must be a positive integer"
  end

  test "error when b is negative" do
    result = Math::GcdLcmCalculator.new(a: 5, b: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Second number must be a positive integer"
  end

  test "both negative returns two errors" do
    result = Math::GcdLcmCalculator.new(a: -5, b: -10).call
    refute result[:valid]
    assert_equal 2, result[:errors].size
  end

  # --- Edge cases ---

  test "large numbers" do
    result = Math::GcdLcmCalculator.new(a: 10_000, b: 15_000).call
    assert result[:valid]
    assert_equal 5000, result[:gcd]
    assert_equal 30_000, result[:lcm]
  end

  test "GCD of 1 and any number is 1" do
    result = Math::GcdLcmCalculator.new(a: 1, b: 999).call
    assert result[:valid]
    assert_equal 1, result[:gcd]
    assert_equal 999, result[:lcm]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::GcdLcmCalculator.new(a: 12, b: 18)
    assert_equal [], calc.errors
  end
end
