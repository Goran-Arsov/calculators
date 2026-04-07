require "test_helper"

class Everyday::PomodoroTimerCalculatorTest < ActiveSupport::TestCase
  # --- Happy path with defaults ---

  test "default settings produce standard pomodoro cycle" do
    result = Everyday::PomodoroTimerCalculator.new.call

    assert result[:valid]
    assert_equal 25, result[:work_minutes]
    assert_equal 5, result[:break_minutes]
    assert_equal 15, result[:long_break_minutes]
    assert_equal 4, result[:sessions_before_long_break]
    # 4*25 + 3*5 + 15 = 100 + 15 + 15 = 130
    assert_equal 130, result[:total_cycle_minutes]
  end

  # --- Custom settings ---

  test "custom work and break durations" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: 50,
      break_minutes: 10,
      long_break_minutes: 30,
      sessions_before_long_break: 2
    ).call

    assert result[:valid]
    # 2*50 + 1*10 + 30 = 100 + 10 + 30 = 140
    assert_equal 140, result[:total_cycle_minutes]
  end

  test "single session means no short breaks" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: 25,
      break_minutes: 5,
      long_break_minutes: 15,
      sessions_before_long_break: 1
    ).call

    assert result[:valid]
    # 1*25 + 0*5 + 15 = 40
    assert_equal 40, result[:total_cycle_minutes]
  end

  # --- Validation: work_minutes ---

  test "work minutes below range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(work_minutes: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Work duration must be between 1 and 120 minutes"
  end

  test "work minutes above range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(work_minutes: 121).call

    refute result[:valid]
    assert_includes result[:errors], "Work duration must be between 1 and 120 minutes"
  end

  # --- Validation: break_minutes ---

  test "break minutes below range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(break_minutes: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Short break must be between 1 and 60 minutes"
  end

  test "break minutes above range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(break_minutes: 61).call

    refute result[:valid]
    assert_includes result[:errors], "Short break must be between 1 and 60 minutes"
  end

  # --- Validation: long_break_minutes ---

  test "long break minutes below range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(long_break_minutes: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Long break must be between 1 and 120 minutes"
  end

  test "long break minutes above range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(long_break_minutes: 121).call

    refute result[:valid]
    assert_includes result[:errors], "Long break must be between 1 and 120 minutes"
  end

  # --- Validation: sessions_before_long_break ---

  test "sessions below range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(sessions_before_long_break: 0).call

    refute result[:valid]
    assert_includes result[:errors], "Sessions before long break must be between 1 and 10"
  end

  test "sessions above range returns error" do
    result = Everyday::PomodoroTimerCalculator.new(sessions_before_long_break: 11).call

    refute result[:valid]
    assert_includes result[:errors], "Sessions before long break must be between 1 and 10"
  end

  # --- Multiple validation errors ---

  test "multiple invalid fields produce multiple errors" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: 0,
      break_minutes: 0,
      long_break_minutes: 0,
      sessions_before_long_break: 0
    ).call

    refute result[:valid]
    assert_equal 4, result[:errors].length
  end

  # --- Edge cases ---

  test "maximum valid values" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: 120,
      break_minutes: 60,
      long_break_minutes: 120,
      sessions_before_long_break: 10
    ).call

    assert result[:valid]
    # 10*120 + 9*60 + 120 = 1200 + 540 + 120 = 1860
    assert_equal 1860, result[:total_cycle_minutes]
  end

  test "minimum valid values" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: 1,
      break_minutes: 1,
      long_break_minutes: 1,
      sessions_before_long_break: 1
    ).call

    assert result[:valid]
    # 1*1 + 0*1 + 1 = 2
    assert_equal 2, result[:total_cycle_minutes]
  end

  # --- String coercion ---

  test "string inputs are coerced to integers" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: "25",
      break_minutes: "5",
      long_break_minutes: "15",
      sessions_before_long_break: "4"
    ).call

    assert result[:valid]
    assert_equal 130, result[:total_cycle_minutes]
  end

  test "empty string inputs treated as zero and produce errors" do
    result = Everyday::PomodoroTimerCalculator.new(
      work_minutes: "",
      break_minutes: "",
      long_break_minutes: "",
      sessions_before_long_break: ""
    ).call

    refute result[:valid]
    assert_equal 4, result[:errors].length
  end
end
