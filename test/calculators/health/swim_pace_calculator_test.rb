require "test_helper"

class Health::SwimPaceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "400m in 8 minutes gives 2:00/100m" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480).call
    assert result[:valid]
    assert_in_delta 120.0, result[:pace_per_100m_seconds], 0.5
    assert_equal "2:00", result[:pace_per_100m_formatted]
  end

  test "100m in 90 seconds gives 1:30/100m" do
    result = Health::SwimPaceCalculator.new(distance: 100, time_seconds: 90).call
    assert result[:valid]
    assert_in_delta 90.0, result[:pace_per_100m_seconds], 0.5
    assert_equal "1:30", result[:pace_per_100m_formatted]
  end

  # --- Yards conversion ---

  test "100 yards pace converted correctly" do
    result = Health::SwimPaceCalculator.new(distance: 100, time_seconds: 90, pool_unit: "yards").call
    assert result[:valid]
    # 90s/100y, converted to meters: 90 * 1.09361 ≈ 98.4/100m
    assert_in_delta 98.4, result[:pace_per_100m_seconds], 1.0
    assert_equal 90.0, result[:pace_per_100y_seconds]
  end

  # --- Estimated times ---

  test "estimated times include 6 standard distances" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480).call
    assert result[:valid]
    assert_equal 7, result[:estimated_times].length
  end

  test "shorter distance estimates are faster" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480).call
    est_50 = result[:estimated_times].find { |e| e[:label] == "50m" }
    est_1500 = result[:estimated_times].find { |e| e[:label] == "1500m" }
    # 50m should have faster pace per 100m than 1500m
    pace_50 = est_50[:estimated_seconds].to_f / 50 * 100
    pace_1500 = est_1500[:estimated_seconds].to_f / 1500 * 100
    assert pace_50 < pace_1500
  end

  # --- Speed calculation ---

  test "speed per hour calculated" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480).call
    assert result[:valid]
    # 400/480 * 3600 = 3000 m/h
    assert_equal 3000, result[:speed_per_hour]
  end

  # --- CSS ---

  test "css pace is included" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480).call
    assert result[:valid]
    assert result[:css_pace][:seconds_per_100m] > 0
  end

  # --- Validation ---

  test "zero distance returns error" do
    result = Health::SwimPaceCalculator.new(distance: 0, time_seconds: 120).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "zero time returns error" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "invalid pool unit returns error" do
    result = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480, pool_unit: "feet").call
    refute result[:valid]
    assert_includes result[:errors], "Pool unit must be meters or yards"
  end

  test "distance over 10000 returns error" do
    result = Health::SwimPaceCalculator.new(distance: 15000, time_seconds: 480).call
    refute result[:valid]
    assert_includes result[:errors], "Distance seems unrealistically high (max 10000)"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::SwimPaceCalculator.new(distance: "400", time_seconds: "480").call
    assert result[:valid]
    assert_in_delta 120.0, result[:pace_per_100m_seconds], 0.5
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::SwimPaceCalculator.new(distance: 400, time_seconds: 480)
    assert_equal [], calc.errors
  end
end
