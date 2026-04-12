require "test_helper"

class Math::ComplexNumberCalculatorTest < ActiveSupport::TestCase
  test "addition of complex numbers" do
    result = Math::ComplexNumberCalculator.new(operation: "add", real1: 3, imag1: 4, real2: 1, imag2: 2).call
    assert result[:valid]
    assert_in_delta 4.0, result[:real], 1e-12
    assert_in_delta 6.0, result[:imaginary], 1e-12
  end

  test "subtraction of complex numbers" do
    result = Math::ComplexNumberCalculator.new(operation: "subtract", real1: 5, imag1: 3, real2: 2, imag2: 1).call
    assert result[:valid]
    assert_in_delta 3.0, result[:real], 1e-12
    assert_in_delta 2.0, result[:imaginary], 1e-12
  end

  test "multiplication of complex numbers" do
    # (3+4i)(1+2i) = 3+6i+4i+8i^2 = 3+10i-8 = -5+10i
    result = Math::ComplexNumberCalculator.new(operation: "multiply", real1: 3, imag1: 4, real2: 1, imag2: 2).call
    assert result[:valid]
    assert_in_delta(-5.0, result[:real], 1e-12)
    assert_in_delta 10.0, result[:imaginary], 1e-12
  end

  test "division of complex numbers" do
    # (4+2i)/(1+1i) = (4+2i)(1-1i)/(1+1) = (4-4i+2i-2i^2)/2 = (6-2i)/2 = 3-i
    result = Math::ComplexNumberCalculator.new(operation: "divide", real1: 4, imag1: 2, real2: 1, imag2: 1).call
    assert result[:valid]
    assert_in_delta 3.0, result[:real], 1e-12
    assert_in_delta(-1.0, result[:imaginary], 1e-12)
  end

  test "division by zero returns error" do
    result = Math::ComplexNumberCalculator.new(operation: "divide", real1: 1, imag1: 0, real2: 0, imag2: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Cannot divide by zero"
  end

  test "magnitude of 3+4i is 5" do
    result = Math::ComplexNumberCalculator.new(operation: "magnitude", real1: 3, imag1: 4).call
    assert result[:valid]
    assert_in_delta 5.0, result[:magnitude], 1e-12
  end

  test "conjugate of 3+4i is 3-4i" do
    result = Math::ComplexNumberCalculator.new(operation: "conjugate", real1: 3, imag1: 4).call
    assert result[:valid]
    assert_in_delta 3.0, result[:real], 1e-12
    assert_in_delta(-4.0, result[:imaginary], 1e-12)
  end

  test "to_polar of 1+0i" do
    result = Math::ComplexNumberCalculator.new(operation: "to_polar", real1: 1, imag1: 0).call
    assert result[:valid]
    assert_in_delta 1.0, result[:r], 1e-12
    assert_in_delta 0.0, result[:theta_degrees], 1e-12
  end

  test "to_polar of 0+1i is r=1 theta=90" do
    result = Math::ComplexNumberCalculator.new(operation: "to_polar", real1: 0, imag1: 1).call
    assert result[:valid]
    assert_in_delta 1.0, result[:r], 1e-12
    assert_in_delta 90.0, result[:theta_degrees], 1e-6
  end

  test "to_rectangular of r=1 theta=90 gives 0+1i" do
    result = Math::ComplexNumberCalculator.new(operation: "to_rectangular", r: 1, theta: 90).call
    assert result[:valid]
    assert_in_delta 0.0, result[:real], 1e-6
    assert_in_delta 1.0, result[:imaginary], 1e-6
  end

  test "unsupported operation returns error" do
    result = Math::ComplexNumberCalculator.new(operation: "sqrt").call
    refute result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::ComplexNumberCalculator.new(operation: "add", real1: 1, imag1: 0, real2: 0, imag2: 1)
    assert_equal [], calc.errors
  end
end
