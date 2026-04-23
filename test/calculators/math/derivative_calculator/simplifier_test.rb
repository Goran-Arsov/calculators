require "test_helper"

class Math::DerivativeCalculator::SimplifierTest < ActiveSupport::TestCase
  S = Math::DerivativeCalculator::Simplifier

  test "passes through numbers and variables" do
    assert_equal [ :num, 5 ], S.call([ :num, 5 ])
    assert_equal [ :var ], S.call([ :var ])
  end

  test "folds constant addition" do
    ast = [ :binop, "+", [ :num, 2 ], [ :num, 3 ] ]
    assert_equal [ :num, 5 ], S.call(ast)
  end

  test "folds constant subtraction" do
    ast = [ :binop, "-", [ :num, 10 ], [ :num, 4 ] ]
    assert_equal [ :num, 6 ], S.call(ast)
  end

  test "folds constant multiplication" do
    ast = [ :binop, "*", [ :num, 4 ], [ :num, 5 ] ]
    assert_equal [ :num, 20 ], S.call(ast)
  end

  test "refuses to divide by zero during constant folding" do
    ast = [ :binop, "/", [ :num, 1 ], [ :num, 0 ] ]
    # Falls through to the binop representation rather than producing Infinity
    assert_equal [ :binop, "/", [ :num, 1 ], [ :num, 0 ] ], S.call(ast)
  end

  test "x + 0 simplifies to x" do
    ast = [ :binop, "+", [ :var ], [ :num, 0 ] ]
    assert_equal [ :var ], S.call(ast)
  end

  test "0 + x simplifies to x" do
    ast = [ :binop, "+", [ :num, 0 ], [ :var ] ]
    assert_equal [ :var ], S.call(ast)
  end

  test "x - x simplifies to 0" do
    ast = [ :binop, "-", [ :var ], [ :var ] ]
    assert_equal [ :num, 0 ], S.call(ast)
  end

  test "0 - x simplifies to negation of x" do
    ast = [ :binop, "-", [ :num, 0 ], [ :var ] ]
    assert_equal [ :neg, [ :var ] ], S.call(ast)
  end

  test "x * 0 simplifies to 0" do
    ast = [ :binop, "*", [ :var ], [ :num, 0 ] ]
    assert_equal [ :num, 0 ], S.call(ast)
  end

  test "x * 1 simplifies to x" do
    ast = [ :binop, "*", [ :var ], [ :num, 1 ] ]
    assert_equal [ :var ], S.call(ast)
  end

  test "x * -1 simplifies to -x" do
    ast = [ :binop, "*", [ :var ], [ :num, -1 ] ]
    assert_equal [ :neg, [ :var ] ], S.call(ast)
  end

  test "x / 1 simplifies to x" do
    ast = [ :binop, "/", [ :var ], [ :num, 1 ] ]
    assert_equal [ :var ], S.call(ast)
  end

  test "x^0 simplifies to 1" do
    ast = [ :binop, "^", [ :var ], [ :num, 0 ] ]
    assert_equal [ :num, 1 ], S.call(ast)
  end

  test "x^1 simplifies to x" do
    ast = [ :binop, "^", [ :var ], [ :num, 1 ] ]
    assert_equal [ :var ], S.call(ast)
  end

  test "negation of zero is zero" do
    assert_equal [ :num, 0 ], S.call([ :neg, [ :num, 0 ] ])
  end

  test "negation of a number collapses the sign" do
    assert_equal [ :num, -3 ], S.call([ :neg, [ :num, 3 ] ])
  end

  test "recurses into function arguments" do
    # sin(x + 0) should become sin(x)
    ast = [ :func, "sin", [ :binop, "+", [ :var ], [ :num, 0 ] ] ]
    assert_equal [ :func, "sin", [ :var ] ], S.call(ast)
  end

  test "handles nil gracefully" do
    assert_nil S.call(nil)
  end
end
