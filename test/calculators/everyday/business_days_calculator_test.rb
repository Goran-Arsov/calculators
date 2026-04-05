require "test_helper"

class Everyday::BusinessDaysCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "one work week Mon to next Mon" do
    # Jan 6 (Mon) to Jan 13 (Mon): 5 business days, 2 weekend days
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13"
    ).call

    assert result[:valid]
    assert_equal 7, result[:calendar_days]
    assert_equal 5, result[:business_days]
    assert_equal 2, result[:weekend_days]
  end

  test "two work weeks" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-20"
    ).call

    assert result[:valid]
    assert_equal 14, result[:calendar_days]
    assert_equal 10, result[:business_days]
    assert_equal 4, result[:weekend_days]
  end

  test "includes only weekdays as business days" do
    # Fri Jan 10 to Mon Jan 13: Fri = 1 business day, Sat+Sun = 2 weekend
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-10", end_date: "2025-01-13"
    ).call

    assert result[:valid]
    assert_equal 1, result[:business_days]
    assert_equal 2, result[:weekend_days]
  end

  test "weekend-only range has zero business days" do
    # Sat Jan 11 to Mon Jan 13
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-11", end_date: "2025-01-13"
    ).call

    assert result[:valid]
    assert_equal 0, result[:business_days]
    assert_equal 2, result[:weekend_days]
  end

  # --- With holidays ---

  test "excludes specified holidays" do
    # Jan 6-13: normally 5 business days; excluding Jan 8 makes it 4
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13",
      exclude_holidays: [ "2025-01-08" ]
    ).call

    assert result[:valid]
    assert_equal 4, result[:business_days]
    assert_equal 1, result[:holidays_excluded]
  end

  test "holiday on weekend is not double-counted" do
    # Jan 11 is Saturday; excluding it should not affect business day count
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13",
      exclude_holidays: [ "2025-01-11" ]
    ).call

    assert result[:valid]
    assert_equal 5, result[:business_days]
    assert_equal 0, result[:holidays_excluded]
  end

  # --- Weeks calculation ---

  test "total weeks calculated correctly" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-02-03"
    ).call

    assert result[:valid]
    assert_in_delta 4.0, result[:total_weeks], 0.1
  end

  # --- Validation errors ---

  test "error when end date is before start date" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-13", end_date: "2025-01-06"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "End date must be after start date"
  end

  test "error with invalid start date" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "invalid", end_date: "2025-01-13"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid start date format"
  end

  test "error with invalid end date" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "invalid"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid end date format"
  end

  # --- Same day ---

  test "same day returns zero business days" do
    result = Everyday::BusinessDaysCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-06"
    ).call

    assert result[:valid]
    assert_equal 0, result[:business_days]
    assert_equal 0, result[:calendar_days]
  end
end
