require "test_helper"

class Math::BooleanAlgebraCalculator::PrinterTest < ActiveSupport::TestCase
  P = Math::BooleanAlgebraCalculator::Printer

  test "literals print as 1 or 0" do
    assert_equal "1", P.call([ :literal, true ])
    assert_equal "0", P.call([ :literal, false ])
  end

  test "variable prints its name" do
    assert_equal "A", P.call([ :var, "A" ])
  end

  test "NOT on a variable uses the compact form" do
    assert_equal "NOT A", P.call([ :not, [ :var, "A" ] ])
  end

  test "NOT on a compound expression uses parentheses" do
    ast = [ :not, [ :and, [ :var, "A" ], [ :var, "B" ] ] ]
    assert_equal "NOT (A AND B)", P.call(ast)
  end

  test "AND/OR/XOR use keyword spacing" do
    assert_equal "A AND B", P.call([ :and, [ :var, "A" ], [ :var, "B" ] ])
    assert_equal "A OR B",  P.call([ :or,  [ :var, "A" ], [ :var, "B" ] ])
    assert_equal "A XOR B", P.call([ :xor, [ :var, "A" ], [ :var, "B" ] ])
  end

  test "parenthesizes lower-precedence children" do
    # (A OR B) AND C — OR is lower than AND, so it must be parenthesized
    ast = [ :and, [ :or, [ :var, "A" ], [ :var, "B" ] ], [ :var, "C" ] ]
    assert_equal "(A OR B) AND C", P.call(ast)
  end

  test "omits unnecessary parentheses at same or higher precedence" do
    # A AND B AND C — same precedence, no parens needed
    ast = [ :and, [ :and, [ :var, "A" ], [ :var, "B" ] ], [ :var, "C" ] ]
    assert_equal "A AND B AND C", P.call(ast)
  end
end
