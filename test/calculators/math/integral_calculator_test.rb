require "test_helper"

class Math::IntegralCalculatorTest < ActiveSupport::TestCase
  # --- Polynomials (Simpson's rule is exact for cubics) ---

  test "integral of x from 0 to 1 equals 1/2" do
    result = Math::IntegralCalculator.new(expression: "x", lower: 0, upper: 1).call
    assert result[:valid]
    assert_in_delta 0.5, result[:result], 1e-9
  end

  test "integral of x^2 from 0 to 1 equals 1/3" do
    result = Math::IntegralCalculator.new(expression: "x^2", lower: 0, upper: 1).call
    assert result[:valid]
    assert_in_delta 1.0 / 3.0, result[:result], 1e-9
  end

  test "integral of x^3 from 0 to 2 equals 4" do
    result = Math::IntegralCalculator.new(expression: "x^3", lower: 0, upper: 2).call
    assert result[:valid]
    assert_in_delta 4.0, result[:result], 1e-9
  end

  test "integral of 2*x + 3 from 1 to 4" do
    # antiderivative: x^2 + 3x, evaluated 16+12 - (1+3) = 28 - 4 = 24
    result = Math::IntegralCalculator.new(expression: "2*x + 3", lower: 1, upper: 4).call
    assert result[:valid]
    assert_in_delta 24.0, result[:result], 1e-9
  end

  test "constant function: integral of 5 from 0 to 10 equals 50" do
    result = Math::IntegralCalculator.new(expression: "5", lower: 0, upper: 10).call
    assert result[:valid]
    assert_in_delta 50.0, result[:result], 1e-9
  end

  # --- Trigonometric ---

  test "integral of sin(x) from 0 to pi equals 2" do
    result = Math::IntegralCalculator.new(expression: "sin(x)", lower: 0, upper: ::Math::PI).call
    assert result[:valid]
    assert_in_delta 2.0, result[:result], 1e-6
  end

  test "integral of cos(x) from 0 to pi/2 equals 1" do
    result = Math::IntegralCalculator.new(expression: "cos(x)", lower: 0, upper: ::Math::PI / 2).call
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-6
  end

  test "pi constant is recognised" do
    result = Math::IntegralCalculator.new(expression: "sin(x)", lower: 0, upper: "pi".to_f.zero? ? ::Math::PI : ::Math::PI).call
    assert result[:valid]
  end

  # --- Exponential and logarithmic ---

  test "integral of exp(x) from 0 to 1 equals e - 1" do
    result = Math::IntegralCalculator.new(expression: "exp(x)", lower: 0, upper: 1).call
    assert result[:valid]
    assert_in_delta ::Math::E - 1, result[:result], 1e-6
  end

  test "integral of 1/x from 1 to e equals 1" do
    result = Math::IntegralCalculator.new(expression: "1/x", lower: 1, upper: ::Math::E).call
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-6
  end

  test "integral of ln(x) from 1 to e equals 1" do
    # antiderivative: x*ln(x) - x, at e: e - e = 0; at 1: 0 - 1 = -1; diff = 1
    result = Math::IntegralCalculator.new(expression: "ln(x)", lower: 1, upper: ::Math::E).call
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-6
  end

  # --- Bound handling ---

  test "swapped bounds flip the sign" do
    result = Math::IntegralCalculator.new(expression: "x^2", lower: 1, upper: 0).call
    assert result[:valid]
    assert_in_delta(-1.0 / 3.0, result[:result], 1e-9)
  end

  test "equal bounds give zero" do
    result = Math::IntegralCalculator.new(expression: "x^2 + 5", lower: 3, upper: 3).call
    assert result[:valid]
    assert_in_delta 0.0, result[:result], 1e-12
  end

  test "negative bounds: integral of x^2 from -1 to 1 equals 2/3" do
    result = Math::IntegralCalculator.new(expression: "x^2", lower: -1, upper: 1).call
    assert result[:valid]
    assert_in_delta 2.0 / 3.0, result[:result], 1e-9
  end

  # --- Expression parsing ---

  test "implicit grouping with parentheses" do
    result = Math::IntegralCalculator.new(expression: "(x+1)*(x-1)", lower: 0, upper: 2).call
    assert result[:valid]
    # antiderivative of x^2 - 1: x^3/3 - x, at 2: 8/3 - 2 = 2/3; at 0: 0; diff = 2/3
    assert_in_delta 2.0 / 3.0, result[:result], 1e-9
  end

  test "unary minus" do
    result = Math::IntegralCalculator.new(expression: "-x^2", lower: 0, upper: 1).call
    assert result[:valid]
    assert_in_delta(-1.0 / 3.0, result[:result], 1e-9)
  end

  test "expression is case-insensitive" do
    result = Math::IntegralCalculator.new(expression: "SIN(X)", lower: 0, upper: ::Math::PI).call
    assert result[:valid]
    assert_in_delta 2.0, result[:result], 1e-6
  end

  test "sqrt function" do
    # integral of sqrt(x) from 0 to 4: (2/3)x^(3/2) at 4 = (2/3)*8 = 16/3
    result = Math::IntegralCalculator.new(expression: "sqrt(x)", lower: 0, upper: 4).call
    assert result[:valid]
    assert_in_delta 16.0 / 3.0, result[:result], 1e-4
  end

  # --- Validation errors ---

  test "blank expression returns error" do
    result = Math::IntegralCalculator.new(expression: "", lower: 0, upper: 1).call
    refute result[:valid]
    assert_includes result[:errors], "Expression cannot be blank"
  end

  test "unknown identifier returns error" do
    result = Math::IntegralCalculator.new(expression: "y + 1", lower: 0, upper: 1).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("unknown identifier") }
  end

  test "unknown function returns error" do
    result = Math::IntegralCalculator.new(expression: "foo(x)", lower: 0, upper: 1).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("unknown function") }
  end

  test "missing closing parenthesis returns error" do
    result = Math::IntegralCalculator.new(expression: "sin(x", lower: 0, upper: 1).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid expression") }
  end

  test "intervals below minimum returns error" do
    result = Math::IntegralCalculator.new(expression: "x", lower: 0, upper: 1, intervals: 1).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("at least") }
  end

  test "intervals above maximum returns error" do
    result = Math::IntegralCalculator.new(expression: "x", lower: 0, upper: 1, intervals: 1_000_000).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("cannot exceed") }
  end

  test "diverging integral returns error" do
    # 1/x from -1 to 1 diverges; Simpson's rule will hit division by zero or infinity
    result = Math::IntegralCalculator.new(expression: "1/x", lower: -1, upper: 1).call
    refute result[:valid]
    assert result[:errors].any?
  end

  # --- Result metadata ---

  test "result hash contains expression and bounds" do
    result = Math::IntegralCalculator.new(expression: "x^2", lower: 0, upper: 1).call
    assert_equal "x^2", result[:expression]
    assert_equal 0.0, result[:lower]
    assert_equal 1.0, result[:upper]
    assert_equal "Simpson's rule", result[:method]
    assert result[:intervals].even?
  end

  test "errors accessor returns empty array before call" do
    calc = Math::IntegralCalculator.new(expression: "x", lower: 0, upper: 1)
    assert_equal [], calc.errors
  end
end
