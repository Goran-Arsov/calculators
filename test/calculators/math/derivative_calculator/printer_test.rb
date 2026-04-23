require "test_helper"

class Math::DerivativeCalculator::PrinterTest < ActiveSupport::TestCase
  P = Math::DerivativeCalculator::Printer

  def print(ast, variable: "x")
    P.call(ast, variable: variable)
  end

  test "integer numbers print without a decimal point" do
    assert_equal "5", print([ :num, 5 ])
    assert_equal "0", print([ :num, 0 ])
  end

  test "fractional numbers retain their decimal representation" do
    assert_equal "2.5", print([ :num, 2.5 ])
  end

  test "variable uses the configured symbol" do
    assert_equal "x", print([ :var ], variable: "x")
    assert_equal "t", print([ :var ], variable: "t")
  end

  test "negation wraps additive subexpressions" do
    # -(x + 1) must keep parens; -x must not
    inner = [ :binop, "+", [ :var ], [ :num, 1 ] ]
    assert_equal "-(x + 1)", print([ :neg, inner ])
    assert_equal "-x", print([ :neg, [ :var ] ])
  end

  test "function calls use standard f(arg) notation" do
    assert_equal "sin(x)", print([ :func, "sin", [ :var ] ])
    assert_equal "cos(2)", print([ :func, "cos", [ :num, 2 ] ])
  end

  test "precedence: multiplication doesn't parenthesize addition children only when needed" do
    # (x + 1) * 2 must keep parens
    ast = [ :binop, "*", [ :binop, "+", [ :var ], [ :num, 1 ] ], [ :num, 2 ] ]
    assert_equal "(x + 1) * 2", print(ast)
  end

  test "equal-precedence right side of subtraction is parenthesized" do
    # x - (x + 1) is ambiguous without parens because - is left-associative
    # So for x - (x + 1) we expect parens to be preserved
    ast = [ :binop, "-", [ :var ], [ :binop, "+", [ :var ], [ :num, 1 ] ] ]
    # The plus is lower precedence than minus, so parens emerge from precedence rule
    assert_equal "x - (x + 1)", print(ast)
  end

  test "right side of division at same precedence gets parens" do
    # x / (y * z) — y*z is same precedence as /, right-side → parens
    ast = [ :binop, "/", [ :var ], [ :binop, "*", [ :var ], [ :var ] ] ]
    assert_equal "x / (x * x)", print(ast)
  end

  test "simple additive expression needs no parentheses" do
    ast = [ :binop, "+", [ :var ], [ :num, 1 ] ]
    assert_equal "x + 1", print(ast)
  end

  test "power prints with caret operator" do
    ast = [ :binop, "^", [ :var ], [ :num, 3 ] ]
    assert_equal "x ^ 3", print(ast)
  end
end
