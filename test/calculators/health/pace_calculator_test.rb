require "test_helper"

class Health::PaceCalculatorTest < ActiveSupport::TestCase
  # --- Mode: pace ---

  test "calculates pace from distance and time" do
    # 10 km in 50 min = 5:00 /km
    result = Health::PaceCalculator.new(mode: "pace", distance_km: 10, time_minutes: 50).call
    assert result[:valid]
    assert_in_delta 5.0, result[:pace_min_per_km], 0.01
    assert_equal "5:00 /km", result[:pace_formatted]
    assert_in_delta 10.0, result[:distance_km], 0.01
    assert_in_delta 50.0, result[:time_minutes], 0.01
  end

  test "pace with non-round numbers" do
    # 5 km in 27 min = 5.4 min/km = 5:24 /km
    result = Health::PaceCalculator.new(mode: "pace", distance_km: 5, time_minutes: 27).call
    assert result[:valid]
    assert_in_delta 5.4, result[:pace_min_per_km], 0.01
    assert_equal "5:24 /km", result[:pace_formatted]
  end

  # --- Mode: time ---

  test "calculates time from distance and pace" do
    # 10 km at 5:00 /km = 50 min
    result = Health::PaceCalculator.new(mode: "time", distance_km: 10, pace_min_per_km: 5).call
    assert result[:valid]
    assert_in_delta 50.0, result[:time_minutes], 0.01
  end

  test "calculates time for half marathon" do
    # 21.1 km at 5:30 /km = 116.05 min
    result = Health::PaceCalculator.new(mode: "time", distance_km: 21.1, pace_min_per_km: 5.5).call
    assert result[:valid]
    assert_in_delta 116.05, result[:time_minutes], 0.01
  end

  # --- Mode: distance ---

  test "calculates distance from pace and time" do
    # 50 min at 5:00 /km = 10 km
    result = Health::PaceCalculator.new(mode: "distance", time_minutes: 50, pace_min_per_km: 5).call
    assert result[:valid]
    assert_in_delta 10.0, result[:distance_km], 0.01
  end

  test "calculates distance for 30 min run" do
    # 30 min at 6:00 /km = 5 km
    result = Health::PaceCalculator.new(mode: "distance", time_minutes: 30, pace_min_per_km: 6).call
    assert result[:valid]
    assert_in_delta 5.0, result[:distance_km], 0.01
  end

  # --- Validation ---

  test "invalid mode returns error" do
    result = Health::PaceCalculator.new(mode: "speed", distance_km: 10, time_minutes: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be pace, time, or distance"
  end

  test "pace mode with missing distance returns error" do
    result = Health::PaceCalculator.new(mode: "pace", time_minutes: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "pace mode with missing time returns error" do
    result = Health::PaceCalculator.new(mode: "pace", distance_km: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "time mode with missing distance returns error" do
    result = Health::PaceCalculator.new(mode: "time", pace_min_per_km: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "time mode with missing pace returns error" do
    result = Health::PaceCalculator.new(mode: "time", distance_km: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Pace must be positive"
  end

  test "distance mode with missing time returns error" do
    result = Health::PaceCalculator.new(mode: "distance", pace_min_per_km: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "distance mode with missing pace returns error" do
    result = Health::PaceCalculator.new(mode: "distance", time_minutes: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Pace must be positive"
  end

  test "zero distance returns error" do
    result = Health::PaceCalculator.new(mode: "pace", distance_km: 0, time_minutes: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "negative time returns error" do
    result = Health::PaceCalculator.new(mode: "pace", distance_km: 10, time_minutes: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::PaceCalculator.new(mode: "pace", distance_km: 10, time_minutes: 50)
    assert_equal [], calc.errors
  end
end
