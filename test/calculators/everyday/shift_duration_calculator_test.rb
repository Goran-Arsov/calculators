require "test_helper"

class Everyday::ShiftDurationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard 9-to-5 shift" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "09:00", end_time: "17:00", break_minutes: 30
    ).call

    assert result[:valid]
    assert_equal 480, result[:total_minutes]
    assert_in_delta 8.0, result[:total_hours], 0.01
    assert_equal 450, result[:paid_minutes]
    assert_in_delta 7.5, result[:paid_hours], 0.01
    refute result[:overnight]
  end

  test "shift with no break" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "08:00", end_time: "12:00", break_minutes: 0
    ).call

    assert result[:valid]
    assert_equal 240, result[:total_minutes]
    assert_in_delta 4.0, result[:total_hours], 0.01
    assert_equal 240, result[:paid_minutes]
  end

  test "overnight shift 22:00 to 06:00" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "22:00", end_time: "06:00", break_minutes: 30
    ).call

    assert result[:valid]
    assert_equal 480, result[:total_minutes]
    assert_in_delta 8.0, result[:total_hours], 0.01
    assert_equal 450, result[:paid_minutes]
    assert result[:overnight]
  end

  test "overnight shift 23:30 to 07:30" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "23:30", end_time: "07:30", break_minutes: 0
    ).call

    assert result[:valid]
    assert_equal 480, result[:total_minutes]
    assert result[:overnight]
  end

  test "short shift" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "14:00", end_time: "16:30", break_minutes: 0
    ).call

    assert result[:valid]
    assert_equal 150, result[:total_minutes]
    assert_in_delta 2.5, result[:total_hours], 0.01
  end

  # --- String coercion ---

  test "break minutes coerced from string" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "09:00", end_time: "17:00", break_minutes: "60"
    ).call

    assert result[:valid]
    assert_equal 420, result[:paid_minutes]
  end

  # --- Validation errors ---

  test "error with invalid start time" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "invalid", end_time: "17:00"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid start time format (use HH:MM)"
  end

  test "error with invalid end time" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "09:00", end_time: "25:00"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid end time format (use HH:MM)"
  end

  test "error when break exceeds shift duration" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "09:00", end_time: "10:00", break_minutes: 90
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Break time cannot exceed shift duration"
  end

  test "error with negative break minutes" do
    result = Everyday::ShiftDurationCalculator.new(
      start_time: "09:00", end_time: "17:00", break_minutes: -10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Break minutes must be zero or positive"
  end
end
