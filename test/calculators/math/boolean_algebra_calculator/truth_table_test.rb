require "test_helper"

class Math::BooleanAlgebraCalculator::TruthTableTest < ActiveSupport::TestCase
  TT = Math::BooleanAlgebraCalculator::TruthTable

  test "single-variable truth table has two rows" do
    ast = [ :var, "A" ]
    rows = TT.build(ast, [ "A" ])
    assert_equal 2, rows.length
    assert_equal({ "A" => true }, rows.find { |r| r[:inputs]["A"] }[:inputs])
  end

  test "two-variable AND gate has four rows, one true" do
    ast = [ :and, [ :var, "A" ], [ :var, "B" ] ]
    rows = TT.build(ast, [ "A", "B" ])
    assert_equal 4, rows.length
    assert_equal 1, rows.count { |r| r[:output] }
  end

  test "OR gate has three true rows out of four" do
    ast = [ :or, [ :var, "A" ], [ :var, "B" ] ]
    rows = TT.build(ast, [ "A", "B" ])
    assert_equal 3, rows.count { |r| r[:output] }
  end

  test "variables appear in assignment in list order" do
    ast = [ :and, [ :var, "X" ], [ :var, "Y" ] ]
    rows = TT.build(ast, [ "X", "Y" ])
    assert rows.first[:inputs].key?("X")
    assert rows.first[:inputs].key?("Y")
  end

  test "XOR of A and B gives two true rows" do
    ast = [ :xor, [ :var, "A" ], [ :var, "B" ] ]
    rows = TT.build(ast, [ "A", "B" ])
    assert_equal 2, rows.count { |r| r[:output] }
  end
end
