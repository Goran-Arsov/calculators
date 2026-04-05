require "test_helper"

class Everyday::WorkBreakCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "8-hour shift gets rest breaks and meal break" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 8).call

    assert result[:valid]
    assert_equal 8.0, result[:shift_hours]
    assert result[:total_breaks] >= 2
    assert result[:total_break_minutes] > 0
    assert result[:net_work_hours] < 8.0
  end

  test "4-hour shift gets one rest break only" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 4).call

    assert result[:valid]
    assert_equal 1, result[:total_breaks]
    assert_equal 15, result[:total_break_minutes]
  end

  test "3-hour shift gets no breaks" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 3).call

    assert result[:valid]
    assert_equal 0, result[:total_breaks]
    assert_equal 0, result[:total_break_minutes]
    assert_in_delta 3.0, result[:net_work_hours], 0.01
  end

  test "12-hour shift gets multiple breaks including second meal" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 12).call

    assert result[:valid]
    assert result[:total_breaks] >= 4
    assert result[:break_schedule].any? { |b| b[:type] == "Meal break" }
  end

  test "net work time is shift minus breaks" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 8).call

    assert result[:valid]
    expected_net = (8 * 60) - result[:total_break_minutes]
    assert_equal expected_net, result[:net_work_minutes]
  end

  # --- Custom thresholds ---

  test "custom break threshold of 4 hours triggers meal break earlier" do
    result = Everyday::WorkBreakCalculator.new(
      shift_hours: 5, break_threshold: 4, break_duration: 20
    ).call

    assert result[:valid]
    meal_breaks = result[:break_schedule].select { |b| b[:type] == "Meal break" }
    assert_equal 1, meal_breaks.size
    assert_equal 20, meal_breaks.first[:duration]
  end

  test "custom meal threshold" do
    result = Everyday::WorkBreakCalculator.new(
      shift_hours: 8, meal_threshold: 8, meal_duration: 45
    ).call

    assert result[:valid]
    meal_breaks = result[:break_schedule].select { |b| b[:type] == "Meal break" && b[:duration] == 45 }
    assert_equal 1, meal_breaks.size
  end

  # --- Break schedule ordering ---

  test "break schedule is sorted by after_hours" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 12).call

    assert result[:valid]
    hours = result[:break_schedule].map { |b| b[:after_hours] }
    assert_equal hours.sort, hours
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: "8").call

    assert result[:valid]
    assert_equal 8.0, result[:shift_hours]
  end

  # --- Validation errors ---

  test "error when shift hours is zero" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Shift hours must be positive"
  end

  test "error when shift hours exceeds 24" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 25).call

    refute result[:valid]
    assert_includes result[:errors], "Shift hours cannot exceed 24"
  end

  test "error when break duration is zero" do
    result = Everyday::WorkBreakCalculator.new(shift_hours: 8, break_duration: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Break duration must be positive"
  end
end
