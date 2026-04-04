require "test_helper"

class Health::SleepCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: wake_time mode ---

  test "wake_time mode returns 4 suggestions" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "07:00").call
    assert result[:valid]
    assert_equal 4, result[:suggestions].length
  end

  test "wake_time mode suggests correct bedtimes for 7:00 AM" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "07:00").call
    assert result[:valid]
    suggestions = result[:suggestions]

    # 6 cycles: 9h sleep + 15 min = 9h15m before 7:00 => 21:45
    assert_equal "21:45", suggestions[0][:time]
    assert_equal 6, suggestions[0][:cycles]
    assert_in_delta 9.0, suggestions[0][:sleep_hours], 0.01

    # 5 cycles: 7.5h sleep + 15 min = 7h45m before 7:00 => 23:15
    assert_equal "23:15", suggestions[1][:time]
    assert_equal 5, suggestions[1][:cycles]
    assert_in_delta 7.5, suggestions[1][:sleep_hours], 0.01

    # 4 cycles: 6h sleep + 15 min = 6h15m before 7:00 => 00:45
    assert_equal "00:45", suggestions[2][:time]
    assert_equal 4, suggestions[2][:cycles]
    assert_in_delta 6.0, suggestions[2][:sleep_hours], 0.01

    # 3 cycles: 4.5h sleep + 15 min = 4h45m before 7:00 => 02:15
    assert_equal "02:15", suggestions[3][:time]
    assert_equal 3, suggestions[3][:cycles]
    assert_in_delta 4.5, suggestions[3][:sleep_hours], 0.01
  end

  # --- Happy path: bed_time mode ---

  test "bed_time mode returns 4 suggestions" do
    result = Health::SleepCalculator.new(mode: "bed_time", time: "22:00").call
    assert result[:valid]
    assert_equal 4, result[:suggestions].length
  end

  test "bed_time mode suggests correct wake times for 10:00 PM" do
    result = Health::SleepCalculator.new(mode: "bed_time", time: "22:00").call
    assert result[:valid]
    suggestions = result[:suggestions]

    # 6 cycles: 9h sleep + 15 min = 9h15m after 22:00 => 07:15
    assert_equal "07:15", suggestions[0][:time]
    assert_equal 6, suggestions[0][:cycles]

    # 5 cycles: 7.5h sleep + 15 min = 7h45m after 22:00 => 05:45
    assert_equal "05:45", suggestions[1][:time]
    assert_equal 5, suggestions[1][:cycles]

    # 4 cycles: 6h sleep + 15 min = 6h15m after 22:00 => 04:15
    assert_equal "04:15", suggestions[2][:time]
    assert_equal 4, suggestions[2][:cycles]

    # 3 cycles: 4.5h sleep + 15 min = 4h45m after 22:00 => 02:45
    assert_equal "02:45", suggestions[3][:time]
    assert_equal 3, suggestions[3][:cycles]
  end

  # --- Edge cases ---

  test "wake_time wraps around midnight correctly" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "05:00").call
    assert result[:valid]
    # 6 cycles: 9h15m before 5:00 => 19:45
    assert_equal "19:45", result[:suggestions][0][:time]
  end

  test "bed_time wraps around midnight correctly" do
    result = Health::SleepCalculator.new(mode: "bed_time", time: "23:00").call
    assert result[:valid]
    # 6 cycles: 9h15m after 23:00 => 08:15
    assert_equal "08:15", result[:suggestions][0][:time]
  end

  # --- Validation ---

  test "invalid mode returns error" do
    result = Health::SleepCalculator.new(mode: "nap", time: "07:00").call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be wake_time or bed_time"
  end

  test "invalid time format returns error" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "7am").call
    refute result[:valid]
    assert_includes result[:errors], "Time must be in HH:MM format"
  end

  test "hours out of range returns error" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "25:00").call
    refute result[:valid]
    assert_includes result[:errors], "Hours must be between 0 and 23"
  end

  test "minutes out of range returns error" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "07:60").call
    refute result[:valid]
    assert_includes result[:errors], "Minutes must be between 0 and 59"
  end

  test "empty time returns error" do
    result = Health::SleepCalculator.new(mode: "wake_time", time: "").call
    refute result[:valid]
    assert_includes result[:errors], "Time must be in HH:MM format"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::SleepCalculator.new(mode: "wake_time", time: "07:00")
    assert_equal [], calc.errors
  end
end
