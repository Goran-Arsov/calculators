require "test_helper"

class Math::PercentageCalculatorTest < ActiveSupport::TestCase
  # --- "of" mode: What is X% of Y? ---

  test "happy path: what is 25% of 200" do
    calc = Math::PercentageCalculator.new(value: 200, percentage: 25, mode: "of")
    result = calc.call

    assert result[:valid]
    assert_equal 50.0, result[:result]
    assert_equal "of", result[:mode]
  end

  test "of mode: 50% of 100" do
    result = Math::PercentageCalculator.new(value: 100, percentage: 50, mode: "of").call
    assert result[:valid]
    assert_equal 50.0, result[:result]
  end

  test "of mode: 100% of a value returns the value itself" do
    result = Math::PercentageCalculator.new(value: 80, percentage: 100, mode: "of").call
    assert result[:valid]
    assert_equal 80.0, result[:result]
  end

  test "of mode: 0% of a value returns 0" do
    result = Math::PercentageCalculator.new(value: 500, percentage: 0, mode: "of").call
    assert result[:valid]
    assert_equal 0.0, result[:result]
  end

  test "of mode: percentage of zero returns zero" do
    result = Math::PercentageCalculator.new(value: 0, percentage: 50, mode: "of").call
    assert result[:valid]
    assert_equal 0.0, result[:result]
  end

  test "of mode: fractional percentage" do
    result = Math::PercentageCalculator.new(value: 200, percentage: 12.5, mode: "of").call
    assert result[:valid]
    assert_equal 25.0, result[:result]
  end

  test "of mode: very large numbers" do
    result = Math::PercentageCalculator.new(value: 1_000_000_000, percentage: 99.99, mode: "of").call
    assert result[:valid]
    assert_in_delta 999_900_000.0, result[:result], 1.0
  end

  test "of mode: negative value" do
    result = Math::PercentageCalculator.new(value: -200, percentage: 25, mode: "of").call
    assert result[:valid]
    assert_equal(-50.0, result[:result])
  end

  # --- "is_what_percent" mode: X is what % of Y? ---

  test "happy path: 50 is what percent of 200" do
    result = Math::PercentageCalculator.new(value: 50, percentage: 200, mode: "is_what_percent").call
    assert result[:valid]
    assert_equal 25.0, result[:result]
  end

  test "is_what_percent mode: equal values returns 100%" do
    result = Math::PercentageCalculator.new(value: 75, percentage: 75, mode: "is_what_percent").call
    assert result[:valid]
    assert_equal 100.0, result[:result]
  end

  test "is_what_percent mode: zero second value returns error" do
    result = Math::PercentageCalculator.new(value: 50, percentage: 0, mode: "is_what_percent").call
    refute result[:valid]
    assert_includes result[:errors], "Second value cannot be zero for 'is what percent'"
  end

  test "is_what_percent mode: negative values" do
    result = Math::PercentageCalculator.new(value: -50, percentage: 200, mode: "is_what_percent").call
    assert result[:valid]
    assert_equal(-25.0, result[:result])
  end

  # --- "change" mode: Percentage change from X to Y ---

  test "happy path: percentage change from 100 to 150 is 50%" do
    result = Math::PercentageCalculator.new(value: 100, percentage: 150, mode: "change").call
    assert result[:valid]
    assert_equal 50.0, result[:result]
  end

  test "change mode: decrease from 200 to 100 is -50%" do
    result = Math::PercentageCalculator.new(value: 200, percentage: 100, mode: "change").call
    assert result[:valid]
    assert_equal(-50.0, result[:result])
  end

  test "change mode: no change returns 0%" do
    result = Math::PercentageCalculator.new(value: 100, percentage: 100, mode: "change").call
    assert result[:valid]
    assert_equal 0.0, result[:result]
  end

  test "change mode: zero original value returns error" do
    result = Math::PercentageCalculator.new(value: 0, percentage: 50, mode: "change").call
    refute result[:valid]
    assert_includes result[:errors], "Value cannot be zero for percentage change"
  end

  test "change mode: negative to positive" do
    result = Math::PercentageCalculator.new(value: -100, percentage: 100, mode: "change").call
    assert result[:valid]
    # (-100 -> 100), change = (100 - (-100)) / |-100| * 100 = 200%
    assert_equal 200.0, result[:result]
  end

  test "change mode: very large percentage change" do
    result = Math::PercentageCalculator.new(value: 1, percentage: 1_000_000, mode: "change").call
    assert result[:valid]
    assert_in_delta 99_999_900.0, result[:result], 1.0
  end

  # --- Validation errors ---

  test "invalid mode returns error" do
    result = Math::PercentageCalculator.new(value: 100, percentage: 50, mode: "invalid").call
    refute result[:valid]
    assert_includes result[:errors], "Invalid mode"
  end

  test "default mode is of" do
    result = Math::PercentageCalculator.new(value: 200, percentage: 10).call
    assert result[:valid]
    assert_equal 20.0, result[:result]
    assert_equal "of", result[:mode]
  end

  test "errors accessor returns empty array before call" do
    calc = Math::PercentageCalculator.new(value: 100, percentage: 50)
    assert_equal [], calc.errors
  end
end
