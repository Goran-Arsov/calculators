require "test_helper"

class Everyday::AlarmTimerCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "hours, minutes, and seconds combined" do
    result = Everyday::AlarmTimerCalculator.new(hours: 1, minutes: 30, seconds: 45).call

    assert result[:valid]
    assert_equal 5445, result[:total_seconds]
    assert_equal "01:30:45", result[:formatted_time]
    assert_equal 1, result[:hours]
    assert_equal 30, result[:minutes]
    assert_equal 45, result[:seconds]
  end

  test "just minutes" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 5, seconds: 0).call

    assert result[:valid]
    assert_equal 300, result[:total_seconds]
    assert_equal "00:05:00", result[:formatted_time]
  end

  test "just seconds" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 0, seconds: 30).call

    assert result[:valid]
    assert_equal 30, result[:total_seconds]
    assert_equal "00:00:30", result[:formatted_time]
  end

  test "just hours" do
    result = Everyday::AlarmTimerCalculator.new(hours: 2, minutes: 0, seconds: 0).call

    assert result[:valid]
    assert_equal 7200, result[:total_seconds]
    assert_equal "02:00:00", result[:formatted_time]
  end

  # --- Total seconds calculation ---

  test "1h 30m 45s equals 5445 seconds" do
    result = Everyday::AlarmTimerCalculator.new(hours: 1, minutes: 30, seconds: 45).call

    assert result[:valid]
    assert_equal 5445, result[:total_seconds]
  end

  # --- Formatted time ---

  test "formatted time has leading zeros" do
    result = Everyday::AlarmTimerCalculator.new(hours: 1, minutes: 5, seconds: 3).call

    assert result[:valid]
    assert_equal "01:05:03", result[:formatted_time]
  end

  # --- Validation: all zeros ---

  test "all zeros returns error" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 0, seconds: 0).call

    refute result[:valid]
    assert_includes result[:errors], "At least one value must be greater than zero"
  end

  # --- Validation: negative hours ---

  test "negative hours returns error" do
    result = Everyday::AlarmTimerCalculator.new(hours: -1, minutes: 5, seconds: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Hours must be between 0 and 23"
  end

  # --- Validation: minutes > 59 ---

  test "minutes greater than 59 returns error" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 60, seconds: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Minutes must be between 0 and 59"
  end

  # --- Validation: seconds > 59 ---

  test "seconds greater than 59 returns error" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 0, seconds: 60).call

    refute result[:valid]
    assert_includes result[:errors], "Seconds must be between 0 and 59"
  end

  # --- Validation: hours > 23 ---

  test "hours greater than 23 returns error" do
    result = Everyday::AlarmTimerCalculator.new(hours: 24, minutes: 0, seconds: 1).call

    refute result[:valid]
    assert_includes result[:errors], "Hours must be between 0 and 23"
  end

  # --- Edge cases ---

  test "maximum values 23:59:59" do
    result = Everyday::AlarmTimerCalculator.new(hours: 23, minutes: 59, seconds: 59).call

    assert result[:valid]
    assert_equal 86399, result[:total_seconds]
    assert_equal "23:59:59", result[:formatted_time]
  end

  test "single second 0:0:1" do
    result = Everyday::AlarmTimerCalculator.new(hours: 0, minutes: 0, seconds: 1).call

    assert result[:valid]
    assert_equal 1, result[:total_seconds]
    assert_equal "00:00:01", result[:formatted_time]
  end

  # --- String coercion ---

  test "string inputs are coerced to integers" do
    result = Everyday::AlarmTimerCalculator.new(hours: "1", minutes: "30", seconds: "45").call

    assert result[:valid]
    assert_equal 5445, result[:total_seconds]
    assert_equal "01:30:45", result[:formatted_time]
  end

  test "empty string inputs treated as zero" do
    result = Everyday::AlarmTimerCalculator.new(hours: "", minutes: "", seconds: "").call

    refute result[:valid]
    assert_includes result[:errors], "At least one value must be greater than zero"
  end
end
