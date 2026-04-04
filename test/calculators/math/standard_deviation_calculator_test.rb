require "test_helper"

class Math::StandardDeviationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic dataset: 2, 4, 4, 4, 5, 5, 7, 9" do
    result = Math::StandardDeviationCalculator.new(values: "2, 4, 4, 4, 5, 5, 7, 9").call
    assert result[:valid]
    assert_equal 8, result[:count]
    assert_equal 5.0, result[:mean]
    assert_equal 4.0, result[:variance]
    assert_equal 2.0, result[:std_dev]
    assert_in_delta 4.5714, result[:sample_variance], 0.001
    assert_in_delta 2.1381, result[:sample_std_dev], 0.001
    assert_equal 2.0, result[:min]
    assert_equal 9.0, result[:max]
    assert_equal 7.0, result[:range]
  end

  test "two identical values" do
    result = Math::StandardDeviationCalculator.new(values: "5, 5").call
    assert result[:valid]
    assert_equal 2, result[:count]
    assert_equal 5.0, result[:mean]
    assert_equal 0.0, result[:variance]
    assert_equal 0.0, result[:std_dev]
    assert_equal 0.0, result[:sample_variance]
    assert_equal 0.0, result[:sample_std_dev]
    assert_equal 0.0, result[:range]
  end

  test "negative numbers" do
    result = Math::StandardDeviationCalculator.new(values: "-5, -3, -1, 1, 3, 5").call
    assert result[:valid]
    assert_equal 6, result[:count]
    assert_equal 0.0, result[:mean]
    assert_equal(-5.0, result[:min])
    assert_equal 5.0, result[:max]
    assert_equal 10.0, result[:range]
  end

  test "decimal numbers" do
    result = Math::StandardDeviationCalculator.new(values: "1.5, 2.5, 3.5").call
    assert result[:valid]
    assert_equal 3, result[:count]
    assert_equal 2.5, result[:mean]
  end

  # --- Validation errors ---

  test "error when fewer than 2 values" do
    result = Math::StandardDeviationCalculator.new(values: "5").call
    refute result[:valid]
    assert_includes result[:errors], "Please enter at least 2 comma-separated numbers"
  end

  test "error when empty string" do
    result = Math::StandardDeviationCalculator.new(values: "").call
    refute result[:valid]
  end

  test "error with invalid number format" do
    result = Math::StandardDeviationCalculator.new(values: "abc, def").call
    refute result[:valid]
  end

  # --- Edge cases ---

  test "large dataset" do
    values = (1..100).to_a.join(", ")
    result = Math::StandardDeviationCalculator.new(values: values).call
    assert result[:valid]
    assert_equal 100, result[:count]
    assert_equal 50.5, result[:mean]
    assert_equal 1.0, result[:min]
    assert_equal 100.0, result[:max]
    assert_equal 99.0, result[:range]
  end

  test "values with extra whitespace" do
    result = Math::StandardDeviationCalculator.new(values: "  1 ,  2 ,  3  ").call
    assert result[:valid]
    assert_equal 3, result[:count]
    assert_equal 2.0, result[:mean]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::StandardDeviationCalculator.new(values: "1, 2, 3")
    assert_equal [], calc.errors
  end
end
