require "test_helper"

class Everyday::TimeCardCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard 9-to-5 with 30 min break at $20/hr" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "17:00", break_minutes: 30, hourly_rate: 20
    ).call

    assert result[:valid]
    assert_in_delta 7.5, result[:hours_worked], 0.01
    assert_in_delta 150.00, result[:gross_pay], 0.01
    assert_in_delta 37.5, result[:weekly_hours], 0.1
    assert_in_delta 750.00, result[:weekly_pay], 0.01
  end

  test "no break and no rate" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "08:00", clock_out: "16:00", break_minutes: 0, hourly_rate: 0
    ).call

    assert result[:valid]
    assert_in_delta 8.0, result[:hours_worked], 0.01
    assert_in_delta 0.00, result[:gross_pay], 0.01
  end

  test "overnight shift 22:00 to 06:00" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "22:00", clock_out: "06:00", break_minutes: 30, hourly_rate: 25
    ).call

    assert result[:valid]
    assert result[:overnight]
    assert_equal 480, result[:total_minutes]
    assert_in_delta 7.5, result[:hours_worked], 0.01
    assert_in_delta 187.50, result[:gross_pay], 0.01
  end

  test "short shift with no break" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "12:00", clock_out: "14:30", break_minutes: 0, hourly_rate: 15
    ).call

    assert result[:valid]
    assert_in_delta 2.5, result[:hours_worked], 0.01
    assert_in_delta 37.50, result[:gross_pay], 0.01
    refute result[:overnight]
  end

  # --- Weekly projection ---

  test "weekly projection is 5x daily" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "17:00", break_minutes: 0, hourly_rate: 20
    ).call

    assert result[:valid]
    assert_in_delta 40.0, result[:weekly_hours], 0.1
    assert_in_delta 800.00, result[:weekly_pay], 0.01
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "17:00", break_minutes: "30", hourly_rate: "20"
    ).call

    assert result[:valid]
    assert_in_delta 7.5, result[:hours_worked], 0.01
  end

  # --- Validation errors ---

  test "error with invalid clock-in time" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "invalid", clock_out: "17:00"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid clock-in time format (use HH:MM)"
  end

  test "error with same clock-in and clock-out" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "09:00"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Clock-in and clock-out times cannot be the same"
  end

  test "error when break exceeds shift" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "10:00", break_minutes: 90
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Break time cannot exceed total shift time"
  end

  test "error with negative hourly rate" do
    result = Everyday::TimeCardCalculator.new(
      clock_in: "09:00", clock_out: "17:00", hourly_rate: -10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hourly rate must be zero or positive"
  end
end
