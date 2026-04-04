require "test_helper"

class Math::PythagoreanCalculatorTest < ActiveSupport::TestCase
  # --- Solve for c (hypotenuse) ---

  test "solve for c: classic 3-4-5 triangle" do
    result = Math::PythagoreanCalculator.new(a: 3, b: 4).call
    assert result[:valid]
    assert_equal 5.0, result[:c]
    assert_equal 3.0, result[:a]
    assert_equal 4.0, result[:b]
    assert_equal "c", result[:solved_for]
  end

  test "solve for c: 5-12-13 triangle" do
    result = Math::PythagoreanCalculator.new(a: 5, b: 12).call
    assert result[:valid]
    assert_equal 13.0, result[:c]
  end

  test "solve for c: non-integer result" do
    result = Math::PythagoreanCalculator.new(a: 1, b: 1).call
    assert result[:valid]
    assert_in_delta 1.4142, result[:c], 0.0001
    assert_equal "c", result[:solved_for]
  end

  # --- Solve for a ---

  test "solve for a: given b and c" do
    result = Math::PythagoreanCalculator.new(b: 4, c: 5).call
    assert result[:valid]
    assert_equal 3.0, result[:a]
    assert_equal "a", result[:solved_for]
  end

  test "solve for a: non-integer result" do
    result = Math::PythagoreanCalculator.new(b: 3, c: 5).call
    assert result[:valid]
    assert_equal 4.0, result[:a]
  end

  # --- Solve for b ---

  test "solve for b: given a and c" do
    result = Math::PythagoreanCalculator.new(a: 3, c: 5).call
    assert result[:valid]
    assert_equal 4.0, result[:b]
    assert_equal "b", result[:solved_for]
  end

  test "solve for b: non-integer result" do
    result = Math::PythagoreanCalculator.new(a: 5, c: 13).call
    assert result[:valid]
    assert_equal 12.0, result[:b]
  end

  # --- Validation errors ---

  test "error when no sides provided" do
    result = Math::PythagoreanCalculator.new.call
    refute result[:valid]
    assert_includes result[:errors], "Exactly 2 sides must be provided"
  end

  test "error when only one side provided" do
    result = Math::PythagoreanCalculator.new(a: 3).call
    refute result[:valid]
    assert_includes result[:errors], "Exactly 2 sides must be provided"
  end

  test "error when all three sides provided" do
    result = Math::PythagoreanCalculator.new(a: 3, b: 4, c: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Exactly 2 sides must be provided"
  end

  test "error when a side is negative" do
    result = Math::PythagoreanCalculator.new(a: -3, b: 4).call
    refute result[:valid]
    assert_includes result[:errors], "Side a must be positive"
  end

  test "error when a side is zero" do
    result = Math::PythagoreanCalculator.new(a: 0, b: 4).call
    refute result[:valid]
    assert_includes result[:errors], "Side a must be positive"
  end

  test "error when hypotenuse is smaller than leg for solving a" do
    result = Math::PythagoreanCalculator.new(b: 10, c: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Hypotenuse c must be greater than side b"
  end

  test "error when hypotenuse is smaller than leg for solving b" do
    result = Math::PythagoreanCalculator.new(a: 10, c: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Hypotenuse c must be greater than side a"
  end

  # --- Edge cases ---

  test "very large numbers" do
    result = Math::PythagoreanCalculator.new(a: 300, b: 400).call
    assert result[:valid]
    assert_equal 500.0, result[:c]
  end

  test "decimal inputs" do
    result = Math::PythagoreanCalculator.new(a: 1.5, b: 2.0).call
    assert result[:valid]
    assert_equal 2.5, result[:c]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::PythagoreanCalculator.new(a: 3, b: 4)
    assert_equal [], calc.errors
  end
end
