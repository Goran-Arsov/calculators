require "test_helper"

class Everyday::DateDifferenceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "30 days apart → total_days=30" do
    start_date = "2025-01-01"
    end_date = "2025-01-31"
    result = Everyday::DateDifferenceCalculator.new(start_date: start_date, end_date: end_date).call
    assert_nil result[:errors]
    assert_equal 30, result[:total_days]
  end

  test "exactly one year apart" do
    result = Everyday::DateDifferenceCalculator.new(start_date: "2024-01-01", end_date: "2025-01-01").call
    assert_nil result[:errors]
    assert_equal 366, result[:total_days] # 2024 is a leap year
    assert_equal 1, result[:years]
  end

  test "returns weeks" do
    result = Everyday::DateDifferenceCalculator.new(start_date: "2025-01-01", end_date: "2025-01-15").call
    assert_nil result[:errors]
    assert_equal 14, result[:total_days]
    assert_equal 2, result[:weeks]
  end

  test "order does not matter (uses absolute difference)" do
    result_forward = Everyday::DateDifferenceCalculator.new(start_date: "2025-01-01", end_date: "2025-02-01").call
    result_reverse = Everyday::DateDifferenceCalculator.new(start_date: "2025-02-01", end_date: "2025-01-01").call
    assert_equal result_forward[:total_days], result_reverse[:total_days]
  end

  # --- Validation errors ---

  test "error with invalid start date" do
    result = Everyday::DateDifferenceCalculator.new(start_date: "invalid", end_date: "2025-01-01").call
    assert result[:errors].any?
    assert_includes result[:errors], "Invalid start date format"
  end

  test "error with invalid end date" do
    result = Everyday::DateDifferenceCalculator.new(start_date: "2025-01-01", end_date: "invalid").call
    assert result[:errors].any?
    assert_includes result[:errors], "Invalid end date format"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DateDifferenceCalculator.new(start_date: "2025-01-01", end_date: "2025-02-01")
    assert_equal [], calc.errors
  end
end
