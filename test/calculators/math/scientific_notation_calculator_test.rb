require "test_helper"

class Math::ScientificNotationCalculatorTest < ActiveSupport::TestCase
  # --- To scientific notation ---

  test "converts 3500000 to scientific" do
    result = Math::ScientificNotationCalculator.new(value: "3500000", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta 3.5, result[:coefficient], 0.0001
    assert_equal 6, result[:exponent]
  end

  test "converts 0.00042 to scientific" do
    result = Math::ScientificNotationCalculator.new(value: "0.00042", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta 4.2, result[:coefficient], 0.0001
    assert_equal(-4, result[:exponent])
  end

  test "converts 1 to scientific" do
    result = Math::ScientificNotationCalculator.new(value: "1", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta 1.0, result[:coefficient], 0.0001
    assert_equal 0, result[:exponent]
  end

  test "converts 299792458 to scientific" do
    result = Math::ScientificNotationCalculator.new(value: "299792458", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta 2.99792458, result[:coefficient], 0.001
    assert_equal 8, result[:exponent]
  end

  # --- To standard form ---

  test "converts 3.5e6 to standard" do
    result = Math::ScientificNotationCalculator.new(value: "3.5e6", mode: "to_standard").call
    assert result[:valid]
    assert_equal "3500000", result[:decimal]
    assert_in_delta 3.5, result[:coefficient], 0.0001
    assert_equal 6, result[:exponent]
  end

  test "converts 4.2e-4 to standard" do
    result = Math::ScientificNotationCalculator.new(value: "4.2e-4", mode: "to_standard").call
    assert result[:valid]
    assert_in_delta 0.00042, result[:decimal].to_f, 0.00001
    assert_equal(-4, result[:exponent])
  end

  test "converts 6.022e23 to standard" do
    result = Math::ScientificNotationCalculator.new(value: "6.022e23", mode: "to_standard").call
    assert result[:valid]
    assert_in_delta 6.022, result[:coefficient], 0.001
    assert_equal 23, result[:exponent]
  end

  # --- Both mode ---

  test "both mode converts 42 to scientific and back" do
    result = Math::ScientificNotationCalculator.new(value: "42", mode: "both").call
    assert result[:valid]
    assert_in_delta 4.2, result[:coefficient], 0.0001
    assert_equal 1, result[:exponent]
    assert_equal "42", result[:decimal]
  end

  # --- Zero ---

  test "zero in to_scientific mode" do
    result = Math::ScientificNotationCalculator.new(value: "0", mode: "to_scientific").call
    assert result[:valid]
    assert_equal 0.0, result[:coefficient]
    assert_equal 0, result[:exponent]
  end

  test "zero in both mode" do
    result = Math::ScientificNotationCalculator.new(value: "0", mode: "both").call
    assert result[:valid]
    assert_equal 0.0, result[:coefficient]
    assert_equal 0, result[:exponent]
  end

  # --- Negative numbers ---

  test "negative number to scientific" do
    result = Math::ScientificNotationCalculator.new(value: "-5600", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta(-5.6, result[:coefficient], 0.0001)
    assert_equal 3, result[:exponent]
  end

  # --- Validation ---

  test "error for invalid number in to_scientific mode" do
    result = Math::ScientificNotationCalculator.new(value: "abc", mode: "to_scientific").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("valid number") }
  end

  test "error for invalid scientific notation in to_standard mode" do
    result = Math::ScientificNotationCalculator.new(value: "not_sci", mode: "to_standard").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("valid scientific notation") }
  end

  test "error for empty value" do
    result = Math::ScientificNotationCalculator.new(value: "", mode: "to_scientific").call
    refute result[:valid]
  end

  test "error for invalid mode" do
    result = Math::ScientificNotationCalculator.new(value: "100", mode: "invalid").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid mode") }
  end

  # --- Edge cases ---

  test "very small number" do
    result = Math::ScientificNotationCalculator.new(value: "0.0000001", mode: "to_scientific").call
    assert result[:valid]
    assert_in_delta 1.0, result[:coefficient], 0.0001
    assert_equal(-7, result[:exponent])
  end

  test "returns scientific and e_notation strings" do
    result = Math::ScientificNotationCalculator.new(value: "1500", mode: "to_scientific").call
    assert result[:valid]
    assert result[:scientific].include?("x 10^")
    assert result[:e_notation].include?("e")
  end

  test "errors accessor returns empty array before call" do
    calc = Math::ScientificNotationCalculator.new(value: "100", mode: "to_scientific")
    assert_equal [], calc.errors
  end
end
