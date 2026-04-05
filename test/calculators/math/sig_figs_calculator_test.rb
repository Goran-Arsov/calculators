require "test_helper"

class Math::SigFigsCalculatorTest < ActiveSupport::TestCase
  # --- Counting sig figs ---

  test "non-zero digits: 1234 has 4 sig figs" do
    result = Math::SigFigsCalculator.new(value: "1234").call
    assert result[:valid]
    assert_equal 4, result[:sig_figs]
  end

  test "leading zeros: 0.0045 has 2 sig figs" do
    result = Math::SigFigsCalculator.new(value: "0.0045").call
    assert result[:valid]
    assert_equal 2, result[:sig_figs]
  end

  test "trailing zeros with decimal: 2.50 has 3 sig figs" do
    result = Math::SigFigsCalculator.new(value: "2.50").call
    assert result[:valid]
    assert_equal 3, result[:sig_figs]
  end

  test "zeros between digits: 1002 has 4 sig figs" do
    result = Math::SigFigsCalculator.new(value: "1002").call
    assert result[:valid]
    assert_equal 4, result[:sig_figs]
  end

  test "trailing zeros without decimal: 1500 has 2 sig figs (ambiguous)" do
    result = Math::SigFigsCalculator.new(value: "1500").call
    assert result[:valid]
    assert_equal 2, result[:sig_figs]
  end

  test "0.00340 has 3 sig figs" do
    result = Math::SigFigsCalculator.new(value: "0.00340").call
    assert result[:valid]
    assert_equal 3, result[:sig_figs]
  end

  test "100.0 has 4 sig figs" do
    result = Math::SigFigsCalculator.new(value: "100.0").call
    assert result[:valid]
    assert_equal 4, result[:sig_figs]
  end

  test "single digit 5 has 1 sig fig" do
    result = Math::SigFigsCalculator.new(value: "5").call
    assert result[:valid]
    assert_equal 1, result[:sig_figs]
  end

  # --- Rounding ---

  test "rounds 3.14159 to 3 sig figs" do
    result = Math::SigFigsCalculator.new(value: "3.14159", round_to: 3).call
    assert result[:valid]
    assert_in_delta 3.14, result[:rounded_value], 0.001
  end

  test "rounds 0.004567 to 2 sig figs" do
    result = Math::SigFigsCalculator.new(value: "0.004567", round_to: 2).call
    assert result[:valid]
    assert_in_delta 0.0046, result[:rounded_value], 0.00001
  end

  test "rounds 1234 to 2 sig figs" do
    result = Math::SigFigsCalculator.new(value: "1234", round_to: 2).call
    assert result[:valid]
    assert_in_delta 1200, result[:rounded_value], 1
  end

  test "no rounding when round_to not specified" do
    result = Math::SigFigsCalculator.new(value: "123.456").call
    assert result[:valid]
    assert_nil result[:rounded_to]
    assert_nil result[:rounded_value]
  end

  # --- Scientific notation ---

  test "returns scientific notation" do
    result = Math::SigFigsCalculator.new(value: "1500").call
    assert result[:valid]
    assert result[:scientific_notation].is_a?(String)
    assert result[:scientific_notation].include?("e")
  end

  # --- Validation ---

  test "error for non-numeric input" do
    result = Math::SigFigsCalculator.new(value: "abc").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("valid number") }
  end

  test "error for negative round_to" do
    result = Math::SigFigsCalculator.new(value: "123", round_to: 0).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("positive") }
  end

  # --- Edge cases ---

  test "negative number preserves sig fig count" do
    result = Math::SigFigsCalculator.new(value: "-0.0045").call
    assert result[:valid]
    assert_equal 2, result[:sig_figs]
  end

  test "very large number" do
    result = Math::SigFigsCalculator.new(value: "6022000000000000000000000").call
    assert result[:valid]
    assert result[:sig_figs] > 0
  end

  test "errors accessor returns empty array before call" do
    calc = Math::SigFigsCalculator.new(value: "123")
    assert_equal [], calc.errors
  end
end
