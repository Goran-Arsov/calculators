require "test_helper"

class Math::LogarithmCalculatorTest < ActiveSupport::TestCase
  # --- Natural log (ln) ---

  test "ln of e is 1" do
    result = Math::LogarithmCalculator.new(value: ::Math::E, base: "e").call
    assert result[:valid]
    assert_in_delta 1.0, result[:result], 0.0001
    assert_in_delta 1.0, result[:ln], 0.0001
  end

  test "ln of 1 is 0" do
    result = Math::LogarithmCalculator.new(value: 1, base: "e").call
    assert result[:valid]
    assert_in_delta 0.0, result[:result], 0.0001
  end

  # --- Log base 10 ---

  test "log10 of 100 is 2" do
    result = Math::LogarithmCalculator.new(value: 100, base: "10").call
    assert result[:valid]
    assert_in_delta 2.0, result[:result], 0.0001
    assert_in_delta 2.0, result[:log10], 0.0001
  end

  test "log10 of 1000 is 3" do
    result = Math::LogarithmCalculator.new(value: 1000, base: "10").call
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 0.0001
  end

  # --- Log base 2 ---

  test "log2 of 8 is 3" do
    result = Math::LogarithmCalculator.new(value: 8, base: "2").call
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 0.0001
    assert_in_delta 3.0, result[:log2], 0.0001
  end

  test "log2 of 1024 is 10" do
    result = Math::LogarithmCalculator.new(value: 1024, base: "2").call
    assert result[:valid]
    assert_in_delta 10.0, result[:result], 0.0001
  end

  # --- Custom base ---

  test "log base 5 of 125 is 3" do
    result = Math::LogarithmCalculator.new(value: 125, base: "5").call
    assert result[:valid]
    assert_in_delta 3.0, result[:result], 0.0001
  end

  # --- All results returned ---

  test "returns ln, log10, and log2 simultaneously" do
    result = Math::LogarithmCalculator.new(value: 100, base: "e").call
    assert result[:valid]
    assert result[:ln].is_a?(Float)
    assert result[:log10].is_a?(Float)
    assert result[:log2].is_a?(Float)
  end

  # --- Validation errors ---

  test "error when value is zero" do
    result = Math::LogarithmCalculator.new(value: 0, base: "10").call
    refute result[:valid]
    assert_includes result[:errors], "Value must be a positive number"
  end

  test "error when value is negative" do
    result = Math::LogarithmCalculator.new(value: -5, base: "10").call
    refute result[:valid]
    assert_includes result[:errors], "Value must be a positive number"
  end

  test "error when base is 1" do
    result = Math::LogarithmCalculator.new(value: 10, base: "1").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("positive number not equal to 1") }
  end

  test "error when base is 0" do
    result = Math::LogarithmCalculator.new(value: 10, base: "0").call
    refute result[:valid]
  end

  test "error when base is invalid string" do
    result = Math::LogarithmCalculator.new(value: 10, base: "abc").call
    refute result[:valid]
  end

  # --- Edge cases ---

  test "very large value" do
    result = Math::LogarithmCalculator.new(value: 1_000_000_000, base: "10").call
    assert result[:valid]
    assert_in_delta 9.0, result[:result], 0.0001
  end

  test "very small positive value" do
    result = Math::LogarithmCalculator.new(value: 0.001, base: "10").call
    assert result[:valid]
    assert_in_delta(-3.0, result[:result], 0.0001)
  end

  test "string coercion of value" do
    result = Math::LogarithmCalculator.new(value: "100", base: "10").call
    assert result[:valid]
    assert_in_delta 2.0, result[:result], 0.0001
  end

  test "errors accessor returns empty array before call" do
    calc = Math::LogarithmCalculator.new(value: 10, base: "10")
    assert_equal [], calc.errors
  end
end
