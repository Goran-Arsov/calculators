require "test_helper"

class Everyday::WorkHoursCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "one work week Mon-Fri at 8 hours per day" do
    # Jan 6 2025 is a Monday, Jan 13 is next Monday
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 8, days_per_week: 5
    ).call

    assert result[:valid]
    assert_equal 7, result[:calendar_days]
    assert_equal 5, result[:work_days]
    assert_in_delta 40.0, result[:total_hours], 0.1
  end

  test "two weeks of work" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-20", hours_per_day: 8, days_per_week: 5
    ).call

    assert result[:valid]
    assert_equal 14, result[:calendar_days]
    assert_equal 10, result[:work_days]
    assert_in_delta 80.0, result[:total_hours], 0.1
  end

  test "six-day work week counts Saturdays" do
    # Jan 6 (Mon) to Jan 13 (Mon): Mon-Sat = 6 work days
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 8, days_per_week: 6
    ).call

    assert result[:valid]
    assert_equal 6, result[:work_days]
    assert_in_delta 48.0, result[:total_hours], 0.1
  end

  test "seven-day work week counts all days" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 8, days_per_week: 7
    ).call

    assert result[:valid]
    assert_equal 7, result[:work_days]
    assert_in_delta 56.0, result[:total_hours], 0.1
  end

  test "custom hours per day" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 6, days_per_week: 5
    ).call

    assert result[:valid]
    assert_equal 5, result[:work_days]
    assert_in_delta 30.0, result[:total_hours], 0.1
  end

  test "same day returns zero work days" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-06", hours_per_day: 8, days_per_week: 5
    ).call

    assert result[:valid]
    assert_equal 0, result[:work_days]
    assert_in_delta 0.0, result[:total_hours], 0.1
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: "8", days_per_week: "5"
    ).call

    assert result[:valid]
    assert_equal 5, result[:work_days]
  end

  # --- Weeks calculation ---

  test "weeks are calculated correctly" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-02-03", hours_per_day: 8, days_per_week: 5
    ).call

    assert result[:valid]
    assert_equal 28, result[:calendar_days]
    assert_in_delta 4.0, result[:total_weeks], 0.1
  end

  # --- Validation errors ---

  test "error when end date is before start date" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-13", end_date: "2025-01-06", hours_per_day: 8, days_per_week: 5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "End date must be after start date"
  end

  test "error with invalid date format" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "invalid", end_date: "2025-01-13", hours_per_day: 8, days_per_week: 5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid start date format"
  end

  test "error when hours per day is zero" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 0, days_per_week: 5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hours per day must be between 0 and 24"
  end

  test "error when days per week is zero" do
    result = Everyday::WorkHoursCalculator.new(
      start_date: "2025-01-06", end_date: "2025-01-13", hours_per_day: 8, days_per_week: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Days per week must be between 1 and 7"
  end
end
