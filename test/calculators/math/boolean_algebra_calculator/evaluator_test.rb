require "test_helper"

class Math::BooleanAlgebraCalculator::EvaluatorTest < ActiveSupport::TestCase
  E = Math::BooleanAlgebraCalculator::Evaluator

  test "literal evaluates to its stored boolean" do
    assert_equal true, E.evaluate([ :literal, true ], {})
    assert_equal false, E.evaluate([ :literal, false ], {})
  end

  test "variable lookup is case-insensitive and accepts symbols" do
    node = [ :var, "A" ]
    assert_equal true, E.evaluate(node, { "A" => true })
    assert_equal true, E.evaluate(node, { "a" => true })
    assert_equal true, E.evaluate(node, { A: true })
    assert_equal true, E.evaluate(node, { a: true })
  end

  test "missing variable treats as false" do
    assert_equal false, E.evaluate([ :var, "X" ], {})
  end

  test "NOT inverts" do
    assert_equal false, E.evaluate([ :not, [ :literal, true ] ], {})
  end

  test "AND/OR/XOR follow standard truth tables" do
    t = [ :literal, true ]
    f = [ :literal, false ]

    assert_equal true,  E.evaluate([ :and, t, t ], {})
    assert_equal false, E.evaluate([ :and, t, f ], {})
    assert_equal true,  E.evaluate([ :or, f, t ], {})
    assert_equal false, E.evaluate([ :or, f, f ], {})
    assert_equal true,  E.evaluate([ :xor, t, f ], {})
    assert_equal false, E.evaluate([ :xor, t, t ], {})
  end
end
