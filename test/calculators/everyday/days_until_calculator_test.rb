require "test_helper"

class Everyday::DaysUntilCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: future date ---

  test "10 days into the future" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-01-16", from_date: "2025-01-06"
    ).call

    assert result[:valid]
    assert_equal 10, result[:total_days]
    assert_equal 10, result[:absolute_days]
    assert_equal 1, result[:weeks]
    assert_equal 3, result[:remaining_days]
    assert_equal 240, result[:total_hours]
    assert_equal 14400, result[:total_minutes]
    refute result[:past]
  end

  test "business days excludes weekends" do
    # Jan 6 (Mon) to Jan 13 (Mon) = 5 business days
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-01-13", from_date: "2025-01-06"
    ).call

    assert result[:valid]
    assert_equal 5, result[:business_days]
  end

  test "two weeks business days" do
    # Jan 6 (Mon) to Jan 20 (Mon) = 10 business days
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-01-20", from_date: "2025-01-06"
    ).call

    assert result[:valid]
    assert_equal 10, result[:business_days]
  end

  # --- Past date ---

  test "past date returns negative days" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-01-01", from_date: "2025-01-11"
    ).call

    assert result[:valid]
    assert_equal(-10, result[:total_days])
    assert_equal 10, result[:absolute_days]
    assert result[:past]
  end

  test "past date business days are negative" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-01-06", from_date: "2025-01-13"
    ).call

    assert result[:valid]
    assert_equal(-5, result[:business_days])
  end

  # --- Same day ---

  test "same day returns zero" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-06-15", from_date: "2025-06-15"
    ).call

    assert result[:valid]
    assert_equal 0, result[:total_days]
    assert_equal 0, result[:absolute_days]
    assert_equal 0, result[:business_days]
  end

  # --- Month calculation ---

  test "months calculated across year boundary" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2026-03-01", from_date: "2025-01-01"
    ).call

    assert result[:valid]
    assert_equal 14, result[:months]
  end

  # --- Validation errors ---

  test "error with invalid target date" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "invalid", from_date: "2025-01-01"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid target date format"
  end

  test "error with invalid from date" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: "2025-12-31", from_date: "invalid"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid from date format"
  end

  # --- String coercion ---

  test "Date objects accepted as input" do
    result = Everyday::DaysUntilCalculator.new(
      target_date: Date.new(2025, 1, 16), from_date: Date.new(2025, 1, 6)
    ).call

    assert result[:valid]
    assert_equal 10, result[:total_days]
  end
end
