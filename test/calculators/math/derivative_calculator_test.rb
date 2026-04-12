require "test_helper"

class Math::DerivativeCalculatorTest < ActiveSupport::TestCase
  test "derivative of constant is zero" do
    result = Math::DerivativeCalculator.new(expression: "5").call
    assert result[:valid]
    assert_equal "0", result[:derivative]
  end

  test "derivative of x is 1" do
    result = Math::DerivativeCalculator.new(expression: "x").call
    assert result[:valid]
    assert_equal "1", result[:derivative]
  end

  test "power rule: derivative of x^2 is 2 * x" do
    result = Math::DerivativeCalculator.new(expression: "x^2").call
    assert result[:valid]
    assert_includes result[:derivative], "2"
    assert_includes result[:derivative], "x"
  end

  test "power rule: derivative of x^3 is 3 * x^2" do
    result = Math::DerivativeCalculator.new(expression: "x^3").call
    assert result[:valid]
    assert_includes result[:derivative], "3"
  end

  test "derivative of sin(x) is cos(x)" do
    result = Math::DerivativeCalculator.new(expression: "sin(x)").call
    assert result[:valid]
    assert_includes result[:derivative], "cos(x)"
  end

  test "derivative of cos(x) is -sin(x)" do
    result = Math::DerivativeCalculator.new(expression: "cos(x)").call
    assert result[:valid]
    assert_includes result[:derivative], "sin(x)"
  end

  test "derivative of exp(x) is exp(x)" do
    result = Math::DerivativeCalculator.new(expression: "exp(x)").call
    assert result[:valid]
    assert_includes result[:derivative], "exp(x)"
  end

  test "derivative of ln(x) is 1/x" do
    result = Math::DerivativeCalculator.new(expression: "ln(x)").call
    assert result[:valid]
    assert_includes result[:derivative], "1"
    assert_includes result[:derivative], "x"
  end

  test "sum rule: derivative of x^2 + x is 2*x + 1" do
    result = Math::DerivativeCalculator.new(expression: "x^2 + x").call
    assert result[:valid]
    assert_includes result[:derivative], "2"
  end

  test "product rule: derivative of x * sin(x)" do
    result = Math::DerivativeCalculator.new(expression: "x * sin(x)").call
    assert result[:valid]
    assert_includes result[:derivative], "sin(x)"
    assert_includes result[:derivative], "cos(x)"
  end

  test "chain rule: derivative of sin(x^2)" do
    result = Math::DerivativeCalculator.new(expression: "sin(x^2)").call
    assert result[:valid]
    assert_includes result[:derivative], "cos"
    assert_includes result[:derivative], "2"
  end

  test "blank expression returns error" do
    result = Math::DerivativeCalculator.new(expression: "").call
    refute result[:valid]
    assert_includes result[:errors], "Expression cannot be blank"
  end

  test "invalid expression returns error" do
    result = Math::DerivativeCalculator.new(expression: "sin(").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid expression") }
  end

  test "returns steps array" do
    result = Math::DerivativeCalculator.new(expression: "x^2").call
    assert result[:valid]
    assert_kind_of Array, result[:steps]
    assert result[:steps].length > 0
  end

  test "errors accessor returns empty array before call" do
    calc = Math::DerivativeCalculator.new(expression: "x^2")
    assert_equal [], calc.errors
  end
end
