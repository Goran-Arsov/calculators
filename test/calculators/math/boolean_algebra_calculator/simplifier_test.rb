require "test_helper"

class Math::BooleanAlgebraCalculator::SimplifierTest < ActiveSupport::TestCase
  S = Math::BooleanAlgebraCalculator::Simplifier

  test "literals and variables pass through unchanged" do
    assert_equal [ :literal, true ], S.call([ :literal, true ])
    assert_equal [ :var, "A" ], S.call([ :var, "A" ])
  end

  test "double negation cancels: NOT NOT A = A" do
    ast = [ :not, [ :not, [ :var, "A" ] ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end

  test "NOT of literal flips value" do
    assert_equal [ :literal, false ], S.call([ :not, [ :literal, true ] ])
    assert_equal [ :literal, true ], S.call([ :not, [ :literal, false ] ])
  end

  test "AND identity: A AND 1 = A" do
    ast = [ :and, [ :var, "A" ], [ :literal, true ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end

  test "AND annihilation: A AND 0 = 0" do
    ast = [ :and, [ :var, "A" ], [ :literal, false ] ]
    assert_equal [ :literal, false ], S.call(ast)
  end

  test "AND idempotence: A AND A = A" do
    ast = [ :and, [ :var, "A" ], [ :var, "A" ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end

  test "AND complement: A AND NOT A = 0" do
    ast = [ :and, [ :var, "A" ], [ :not, [ :var, "A" ] ] ]
    assert_equal [ :literal, false ], S.call(ast)
  end

  test "OR identity: A OR 0 = A" do
    ast = [ :or, [ :var, "A" ], [ :literal, false ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end

  test "OR annihilation: A OR 1 = 1" do
    ast = [ :or, [ :var, "A" ], [ :literal, true ] ]
    assert_equal [ :literal, true ], S.call(ast)
  end

  test "OR complement: A OR NOT A = 1" do
    ast = [ :or, [ :var, "A" ], [ :not, [ :var, "A" ] ] ]
    assert_equal [ :literal, true ], S.call(ast)
  end

  test "XOR with 0 is identity: A XOR 0 = A" do
    ast = [ :xor, [ :var, "A" ], [ :literal, false ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end

  test "XOR with 1 flips: A XOR 1 = NOT A" do
    ast = [ :xor, [ :var, "A" ], [ :literal, true ] ]
    assert_equal [ :not, [ :var, "A" ] ], S.call(ast)
  end

  test "XOR with self is zero: A XOR A = 0" do
    ast = [ :xor, [ :var, "A" ], [ :var, "A" ] ]
    assert_equal [ :literal, false ], S.call(ast)
  end

  test "recursively simplifies children" do
    # (A AND 1) OR 0 = A
    ast = [ :or, [ :and, [ :var, "A" ], [ :literal, true ] ], [ :literal, false ] ]
    assert_equal [ :var, "A" ], S.call(ast)
  end
end
