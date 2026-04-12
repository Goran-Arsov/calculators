require "test_helper"

class Math::BooleanAlgebraCalculatorTest < ActiveSupport::TestCase
  # --- Simplification ---

  test "simplify A AND 1 equals A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND 1", operation: "simplify").call
    assert result[:valid]
    assert_equal "A", result[:simplified]
  end

  test "simplify A OR 0 equals A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A OR 0", operation: "simplify").call
    assert result[:valid]
    assert_equal "A", result[:simplified]
  end

  test "simplify A AND 0 equals 0" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND 0", operation: "simplify").call
    assert result[:valid]
    assert_equal "0", result[:simplified]
  end

  test "simplify A OR 1 equals 1" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A OR 1", operation: "simplify").call
    assert result[:valid]
    assert_equal "1", result[:simplified]
  end

  test "simplify double negation NOT NOT A equals A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "NOT NOT A", operation: "simplify").call
    assert result[:valid]
    assert_equal "A", result[:simplified]
  end

  test "simplify idempotent A AND A equals A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND A", operation: "simplify").call
    assert result[:valid]
    assert_equal "A", result[:simplified]
  end

  test "simplify complement A AND NOT A equals 0" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND NOT A", operation: "simplify").call
    assert result[:valid]
    assert_equal "0", result[:simplified]
  end

  test "simplify A XOR 0 equals A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A XOR 0", operation: "simplify").call
    assert result[:valid]
    assert_equal "A", result[:simplified]
  end

  test "simplify A XOR A equals 0" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A XOR A", operation: "simplify").call
    assert result[:valid]
    assert_equal "0", result[:simplified]
  end

  # --- Evaluation ---

  test "evaluate A AND B with both true" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND B", operation: "evaluate", variables: { "A" => true, "B" => true }).call
    assert result[:valid]
    assert_equal true, result[:result]
  end

  test "evaluate A AND B with one false" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND B", operation: "evaluate", variables: { "A" => true, "B" => false }).call
    assert result[:valid]
    assert_equal false, result[:result]
  end

  test "evaluate A OR B with one true" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A OR B", operation: "evaluate", variables: { "A" => false, "B" => true }).call
    assert result[:valid]
    assert_equal true, result[:result]
  end

  test "evaluate NOT A" do
    result = Math::BooleanAlgebraCalculator.new(expression: "NOT A", operation: "evaluate", variables: { "A" => true }).call
    assert result[:valid]
    assert_equal false, result[:result]
  end

  # --- Truth table ---

  test "truth table for A AND B has 4 rows" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A AND B", operation: "truth_table").call
    assert result[:valid]
    assert_equal 4, result[:truth_table].length
  end

  test "truth table for single variable has 2 rows" do
    result = Math::BooleanAlgebraCalculator.new(expression: "NOT A", operation: "truth_table").call
    assert result[:valid]
    assert_equal 2, result[:truth_table].length
  end

  # --- Alternate syntax ---

  test "supports && syntax" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A && B", operation: "simplify").call
    assert result[:valid]
  end

  test "supports || syntax" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A || B", operation: "simplify").call
    assert result[:valid]
  end

  test "supports ! syntax" do
    result = Math::BooleanAlgebraCalculator.new(expression: "!A", operation: "simplify").call
    assert result[:valid]
  end

  # --- Validation ---

  test "blank expression returns error" do
    result = Math::BooleanAlgebraCalculator.new(expression: "", operation: "simplify").call
    refute result[:valid]
    assert_includes result[:errors], "Expression cannot be blank"
  end

  test "unsupported operation returns error" do
    result = Math::BooleanAlgebraCalculator.new(expression: "A", operation: "nand").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported operation") }
  end

  test "errors accessor returns empty array before call" do
    calc = Math::BooleanAlgebraCalculator.new(expression: "A AND B")
    assert_equal [], calc.errors
  end
end
