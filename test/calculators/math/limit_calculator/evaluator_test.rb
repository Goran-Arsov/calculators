require "test_helper"

class Math::LimitCalculator::EvaluatorTest < ActiveSupport::TestCase
  E = Math::LimitCalculator::Evaluator

  test "evaluates a constant" do
    assert_equal 5, E.evaluate([ :num, 5 ], 999)
  end

  test "evaluates the variable" do
    assert_equal 42, E.evaluate([ :var ], 42)
  end

  test "evaluates negation" do
    assert_equal(-3, E.evaluate([ :neg, [ :var ] ], 3))
  end

  test "evaluates addition" do
    ast = [ :binop, "+", [ :var ], [ :num, 10 ] ]
    assert_equal 13, E.evaluate(ast, 3)
  end

  test "evaluates exponentiation" do
    ast = [ :binop, "^", [ :var ], [ :num, 3 ] ]
    assert_equal 8, E.evaluate(ast, 2)
  end

  test "raises MathError on division by zero" do
    ast = [ :binop, "/", [ :num, 1 ], [ :num, 0 ] ]
    assert_raises(Math::LimitCalculator::MathError) { E.evaluate(ast, 0) }
  end

  test "evaluates sin, cos, and exp" do
    assert_in_delta 0.0, E.evaluate([ :func, "sin", [ :var ] ], 0), 1e-12
    assert_in_delta 1.0, E.evaluate([ :func, "cos", [ :var ] ], 0), 1e-12
    assert_in_delta 1.0, E.evaluate([ :func, "exp", [ :var ] ], 0), 1e-12
  end

  test "evaluates ln and log as natural logarithm" do
    ln_val = E.evaluate([ :func, "ln", [ :var ] ], ::Math::E)
    log_val = E.evaluate([ :func, "log", [ :var ] ], ::Math::E)
    assert_in_delta 1.0, ln_val, 1e-12
    assert_in_delta 1.0, log_val, 1e-12
  end

  test "evaluates abs" do
    assert_equal 5, E.evaluate([ :func, "abs", [ :var ] ], -5)
  end

  test "raises Math::DomainError on sqrt of negative (caller must catch)" do
    ast = [ :func, "sqrt", [ :var ] ]
    assert_raises(::Math::DomainError) { E.evaluate(ast, -1) }
  end
end
