require "test_helper"

class Everyday::AlarmClockCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "valid hour and minute with day" do
    result = Everyday::AlarmClockCalculator.new(hour: 14, minute: 30, day: "monday").call

    assert result[:valid]
    assert_equal "14:30", result[:formatted_time]
    assert_equal 14, result[:hour]
    assert_equal 30, result[:minute]
    assert_equal "monday", result[:formatted_day]
  end

  test "valid hour and minute without day" do
    result = Everyday::AlarmClockCalculator.new(hour: 8, minute: 0).call

    assert result[:valid]
    assert_equal "08:00", result[:formatted_time]
    assert_equal 8, result[:hour]
    assert_equal 0, result[:minute]
    refute result.key?(:formatted_day)
  end

  # --- Formatted time ---

  test "formatted time hour 14 minute 30 returns 14:30" do
    result = Everyday::AlarmClockCalculator.new(hour: 14, minute: 30).call

    assert result[:valid]
    assert_equal "14:30", result[:formatted_time]
  end

  test "formatted time with leading zeros hour 9 minute 5 returns 09:05" do
    result = Everyday::AlarmClockCalculator.new(hour: 9, minute: 5).call

    assert result[:valid]
    assert_equal "09:05", result[:formatted_time]
  end

  # --- Validation: hour > 23 ---

  test "hour greater than 23 returns error" do
    result = Everyday::AlarmClockCalculator.new(hour: 24, minute: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Hour must be between 0 and 23"
  end

  # --- Validation: hour < 0 ---

  test "negative hour returns error" do
    result = Everyday::AlarmClockCalculator.new(hour: -1, minute: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Hour must be between 0 and 23"
  end

  # --- Validation: minute > 59 ---

  test "minute greater than 59 returns error" do
    result = Everyday::AlarmClockCalculator.new(hour: 12, minute: 60).call

    refute result[:valid]
    assert_includes result[:errors], "Minute must be between 0 and 59"
  end

  # --- Validation: minute < 0 ---

  test "negative minute returns error" do
    result = Everyday::AlarmClockCalculator.new(hour: 12, minute: -1).call

    refute result[:valid]
    assert_includes result[:errors], "Minute must be between 0 and 59"
  end

  # --- Edge cases ---

  test "midnight 0:00" do
    result = Everyday::AlarmClockCalculator.new(hour: 0, minute: 0).call

    assert result[:valid]
    assert_equal "00:00", result[:formatted_time]
    assert_equal 0, result[:hour]
    assert_equal 0, result[:minute]
  end

  test "end of day 23:59" do
    result = Everyday::AlarmClockCalculator.new(hour: 23, minute: 59).call

    assert result[:valid]
    assert_equal "23:59", result[:formatted_time]
    assert_equal 23, result[:hour]
    assert_equal 59, result[:minute]
  end

  # --- Day formatting ---

  test "day with date string is passed through" do
    result = Everyday::AlarmClockCalculator.new(hour: 7, minute: 15, day: "2026-04-08").call

    assert result[:valid]
    assert_equal "2026-04-08", result[:formatted_day]
  end

  test "blank day is not included in result" do
    result = Everyday::AlarmClockCalculator.new(hour: 12, minute: 0, day: "").call

    assert result[:valid]
    refute result.key?(:formatted_day)
  end

  test "nil day is not included in result" do
    result = Everyday::AlarmClockCalculator.new(hour: 12, minute: 0, day: nil).call

    assert result[:valid]
    refute result.key?(:formatted_day)
  end

  # --- String coercion ---

  test "string inputs are coerced to integers" do
    result = Everyday::AlarmClockCalculator.new(hour: "14", minute: "30").call

    assert result[:valid]
    assert_equal "14:30", result[:formatted_time]
  end

  test "empty string inputs treated as zero" do
    result = Everyday::AlarmClockCalculator.new(hour: "", minute: "").call

    assert result[:valid]
    assert_equal "00:00", result[:formatted_time]
  end

  # --- Multiple validation errors ---

  test "multiple invalid fields return multiple errors" do
    result = Everyday::AlarmClockCalculator.new(hour: 25, minute: 61).call

    refute result[:valid]
    assert_includes result[:errors], "Hour must be between 0 and 23"
    assert_includes result[:errors], "Minute must be between 0 and 59"
  end
end
