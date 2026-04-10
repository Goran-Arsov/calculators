require "test_helper"

class Math::ScientificCalculatorTest < ActiveSupport::TestCase
  def call(expr, mode: "rad")
    Math::ScientificCalculator.new(expression: expr, mode: mode).call
  end

  # --- Basic arithmetic ---

  test "addition" do
    result = call("2+3")
    assert result[:valid]
    assert_in_delta 5.0, result[:result], 1e-10
  end

  test "subtraction" do
    result = call("10-4")
    assert result[:valid]
    assert_in_delta 6.0, result[:result], 1e-10
  end

  test "multiplication" do
    result = call("6*7")
    assert result[:valid]
    assert_in_delta 42.0, result[:result], 1e-10
  end

  test "division" do
    result = call("20/4")
    assert result[:valid]
    assert_in_delta 5.0, result[:result], 1e-10
  end

  test "order of operations" do
    result = call("2+3*4")
    assert result[:valid]
    assert_in_delta 14.0, result[:result], 1e-10
  end

  test "parentheses override precedence" do
    result = call("(2+3)*4")
    assert result[:valid]
    assert_in_delta 20.0, result[:result], 1e-10
  end

  test "nested parentheses" do
    result = call("((1+2)*(3+4))")
    assert result[:valid]
    assert_in_delta 21.0, result[:result], 1e-10
  end

  test "decimals" do
    result = call("0.5+0.25")
    assert result[:valid]
    assert_in_delta 0.75, result[:result], 1e-10
  end

  test "negative numbers" do
    result = call("-5+3")
    assert result[:valid]
    assert_in_delta -2.0, result[:result], 1e-10
  end

  test "unary minus with parentheses" do
    result = call("-(3+2)")
    assert result[:valid]
    assert_in_delta -5.0, result[:result], 1e-10
  end

  test "division by zero returns error" do
    result = call("5/0")
    refute result[:valid]
    assert_match(/zero/i, result[:errors].first)
  end

  # --- Exponents ---

  test "exponent operator" do
    result = call("2^10")
    assert result[:valid]
    assert_in_delta 1024.0, result[:result], 1e-10
  end

  test "right-associative exponent" do
    result = call("2^3^2")
    assert result[:valid]
    # 2^(3^2) = 2^9 = 512
    assert_in_delta 512.0, result[:result], 1e-10
  end

  # --- Functions ---

  test "sqrt" do
    result = call("sqrt(16)")
    assert result[:valid]
    assert_in_delta 4.0, result[:result], 1e-10
  end

  test "sin in radians" do
    result = call("sin(0)")
    assert result[:valid]
    assert_in_delta 0.0, result[:result], 1e-10
  end

  test "sin 90 degrees" do
    result = call("sin(90)", mode: "deg")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "cos in degrees" do
    result = call("cos(0)", mode: "deg")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "tan 45 degrees" do
    result = call("tan(45)", mode: "deg")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "natural log of e" do
    result = call("ln(e)")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "log base 10 of 1000" do
    result = call("log(1000)")
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 1e-10
  end

  test "exp of 0" do
    result = call("exp(0)")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "abs of negative" do
    result = call("abs(-7)")
    assert result[:valid]
    assert_in_delta 7.0, result[:result], 1e-10
  end

  test "inverse trig asin in degrees" do
    result = call("asin(1)", mode: "deg")
    assert result[:valid]
    assert_in_delta 90.0, result[:result], 1e-10
  end

  # --- Constants ---

  test "pi constant" do
    result = call("pi")
    assert result[:valid]
    assert_in_delta ::Math::PI, result[:result], 1e-10
  end

  test "e constant" do
    result = call("e")
    assert result[:valid]
    assert_in_delta ::Math::E, result[:result], 1e-10
  end

  test "expression using pi" do
    result = call("2*pi")
    assert result[:valid]
    assert_in_delta 2 * ::Math::PI, result[:result], 1e-10
  end

  # --- Factorial ---

  test "factorial" do
    result = call("5!")
    assert result[:valid]
    assert_in_delta 120.0, result[:result], 1e-10
  end

  test "zero factorial" do
    result = call("0!")
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 1e-10
  end

  test "negative factorial returns error" do
    result = call("(-3)!")
    refute result[:valid]
  end

  # --- Complex expressions ---

  test "complex expression with functions" do
    result = call("sqrt(16)+sin(0)*3")
    assert result[:valid]
    assert_in_delta 4.0, result[:result], 1e-10
  end

  test "scientific notation input" do
    result = call("1.5e3+500")
    assert result[:valid]
    assert_in_delta 2000.0, result[:result], 1e-10
  end

  # --- Error cases ---

  test "empty expression returns error" do
    result = call("")
    refute result[:valid]
    assert_includes result[:errors], "Expression is required"
  end

  test "mismatched parentheses returns error" do
    result = call("(2+3")
    refute result[:valid]
  end

  test "unknown identifier returns error" do
    result = call("foo(5)")
    refute result[:valid]
  end

  test "invalid mode returns error" do
    result = Math::ScientificCalculator.new(expression: "1+1", mode: "grad").call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be 'rad' or 'deg'"
  end

  # --- Formatted output ---

  test "integer results formatted without decimals" do
    result = call("2+2")
    assert_equal "4", result[:formatted]
  end

  test "decimal results formatted with precision" do
    result = call("1/3")
    assert result[:valid]
    assert_match(/^0\.3333/, result[:formatted])
  end
end
