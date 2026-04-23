require "test_helper"

class Math::DerivativeCalculator::DifferentiatorTest < ActiveSupport::TestCase
  D = Math::DerivativeCalculator::Differentiator

  test "constant derivative is zero" do
    assert_equal [ :num, 0 ], D.call([ :num, 5 ])
  end

  test "variable derivative is one" do
    assert_equal [ :num, 1 ], D.call([ :var ])
  end

  test "negation distributes over derivative" do
    assert_equal [ :neg, [ :num, 1 ] ], D.call([ :neg, [ :var ] ])
  end

  test "sum rule: d/dx(x + x) = 1 + 1" do
    ast = [ :binop, "+", [ :var ], [ :var ] ]
    assert_equal [ :binop, "+", [ :num, 1 ], [ :num, 1 ] ], D.call(ast)
  end

  test "product rule produces u'v + uv'" do
    # d/dx(x * 5) = 1 * 5 + x * 0
    ast = [ :binop, "*", [ :var ], [ :num, 5 ] ]
    expected = [ :binop, "+",
      [ :binop, "*", [ :num, 1 ], [ :num, 5 ] ],
      [ :binop, "*", [ :var ], [ :num, 0 ] ] ]
    assert_equal expected, D.call(ast)
  end

  test "power rule with constant exponent: d/dx(x^3)" do
    ast = [ :binop, "^", [ :var ], [ :num, 3 ] ]
    # Expected shape: 3 * x^(3-1) * 1
    result = D.call(ast)
    assert_equal :binop, result[0]
    assert_equal "*", result[1]
  end

  test "chain rule for sin: d/dx(sin(x)) = cos(x) * 1" do
    ast = [ :func, "sin", [ :var ] ]
    expected = [ :binop, "*", [ :func, "cos", [ :var ] ], [ :num, 1 ] ]
    assert_equal expected, D.call(ast)
  end

  test "chain rule for exp: d/dx(exp(x)) = exp(x) * 1" do
    ast = [ :func, "exp", [ :var ] ]
    expected = [ :binop, "*", [ :func, "exp", [ :var ] ], [ :num, 1 ] ]
    assert_equal expected, D.call(ast)
  end

  test "ln and log produce the same derivative rule" do
    ln_result = D.call([ :func, "ln", [ :var ] ])
    log_result = D.call([ :func, "log", [ :var ] ])
    assert_equal ln_result, log_result
  end

  test "unknown function yields zero" do
    ast = [ :func, "unknown", [ :var ] ]
    # Chain rule: 0 * du
    result = D.call(ast)
    assert_equal [ :binop, "*", [ :num, 0 ], [ :num, 1 ] ], result
  end
end
