require "test_helper"

class Finance::OvertimeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "standard overtime at 1.5x" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: 10, ot_multiplier: 1.5
    ).call

    assert result[:valid]
    assert_in_delta 800.00, result[:regular_pay], 0.01
    assert_in_delta 300.00, result[:overtime_pay], 0.01
    assert_in_delta 1100.00, result[:total_pay], 0.01
    assert_in_delta 30.00, result[:overtime_rate], 0.01
    assert_in_delta 50.0, result[:total_hours], 0.1
    assert_in_delta 22.00, result[:effective_hourly_rate], 0.01
  end

  test "double time overtime at 2x" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 25, regular_hours: 40, overtime_hours: 8, ot_multiplier: 2.0
    ).call

    assert result[:valid]
    assert_in_delta 1000.00, result[:regular_pay], 0.01
    assert_in_delta 400.00, result[:overtime_pay], 0.01
    assert_in_delta 1400.00, result[:total_pay], 0.01
    assert_in_delta 50.00, result[:overtime_rate], 0.01
  end

  test "no overtime hours" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: 0, ot_multiplier: 1.5
    ).call

    assert result[:valid]
    assert_in_delta 800.00, result[:regular_pay], 0.01
    assert_in_delta 0.00, result[:overtime_pay], 0.01
    assert_in_delta 800.00, result[:total_pay], 0.01
    assert_in_delta 20.00, result[:effective_hourly_rate], 0.01
  end

  test "effective hourly rate increases with overtime" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: 20, ot_multiplier: 1.5
    ).call

    assert result[:valid]
    # effective = (800 + 600) / 60 = 23.33
    assert_in_delta 23.33, result[:effective_hourly_rate], 0.01
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: "20", regular_hours: "40", overtime_hours: "10", ot_multiplier: "1.5"
    ).call

    assert result[:valid]
    assert_in_delta 1100.00, result[:total_pay], 0.01
  end

  # --- Edge cases ---

  test "only overtime hours no regular" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 30, regular_hours: 0, overtime_hours: 10, ot_multiplier: 1.5
    ).call

    assert result[:valid]
    assert_in_delta 0.00, result[:regular_pay], 0.01
    assert_in_delta 450.00, result[:overtime_pay], 0.01
    assert_in_delta 45.00, result[:effective_hourly_rate], 0.01
  end

  test "high overtime multiplier" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: 8, ot_multiplier: 3.0
    ).call

    assert result[:valid]
    assert_in_delta 480.00, result[:overtime_pay], 0.01
    assert_in_delta 60.00, result[:overtime_rate], 0.01
  end

  # --- Validation errors ---

  test "error when hourly rate is zero" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 0, regular_hours: 40, overtime_hours: 10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hourly rate must be positive"
  end

  test "error when overtime hours are negative" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: -5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Overtime hours must be zero or positive"
  end

  test "error when OT multiplier is less than 1" do
    result = Finance::OvertimeCalculator.new(
      hourly_rate: 20, regular_hours: 40, overtime_hours: 10, ot_multiplier: 0.5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "OT multiplier must be at least 1.0"
  end
end
