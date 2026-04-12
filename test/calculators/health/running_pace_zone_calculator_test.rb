require "test_helper"

class Health::RunningPaceZoneCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: threshold mode ---

  test "threshold mode 5:00/km returns 5 zones" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300).call
    assert result[:valid]
    assert_equal 5, result[:zones].length
    assert_equal 300, result[:threshold_pace_seconds]
  end

  test "threshold pace formatted correctly" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300).call
    assert_equal "5:00 /km", result[:threshold_pace_formatted]
  end

  # --- Zone percentages ---

  test "zone 1 is 125-140% of threshold" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300).call
    zone1 = result[:zones].find { |z| z[:key] == :zone_1 }
    # 300 * 1.25 = 375, 300 * 1.40 = 420
    assert_equal 375, zone1[:min_pace_seconds]
    assert_equal 420, zone1[:max_pace_seconds]
  end

  test "zone 5 is 78-88% of threshold" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300).call
    zone5 = result[:zones].find { |z| z[:key] == :zone_5 }
    # 300 * 0.78 = 234, 300 * 0.88 = 264
    assert_equal 234, zone5[:min_pace_seconds]
    assert_equal 264, zone5[:max_pace_seconds]
  end

  # --- Race mode: 5K ---

  test "race mode 5k 25:00 calculates threshold" do
    # 25:00 = 1500s for 5km = 300s/km race pace
    # threshold = 300 * 1.06 = 318s/km
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "5k", race_time_seconds: 1500
    ).call
    assert result[:valid]
    assert_in_delta 318, result[:threshold_pace_seconds], 2
    assert_equal "5k", result[:race_distance]
  end

  test "race mode 10k calculates threshold" do
    # 50:00 = 3000s for 10km = 300s/km race pace
    # threshold = 300 * 1.02 = 306
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "10k", race_time_seconds: 3000
    ).call
    assert result[:valid]
    assert_in_delta 306, result[:threshold_pace_seconds], 2
  end

  test "race mode half marathon" do
    # 1:40:00 = 6000s for 21.0975km
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "half_marathon", race_time_seconds: 6000
    ).call
    assert result[:valid]
    assert result[:threshold_pace_seconds] > 0
  end

  test "race mode marathon" do
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "marathon", race_time_seconds: 14400
    ).call
    assert result[:valid]
    assert result[:threshold_pace_seconds] > 0
  end

  # --- Zones are properly ordered ---

  test "zone paces get faster from zone 1 to zone 5" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300).call
    zones = result[:zones]
    # Zone 1 (slowest) to Zone 5 (fastest)
    assert zones[0][:max_pace_seconds] > zones[4][:max_pace_seconds]
  end

  # --- Validation ---

  test "invalid mode returns error" do
    result = Health::RunningPaceZoneCalculator.new(mode: "invalid", threshold_pace_seconds: 300).call
    refute result[:valid]
    assert_includes result[:errors], "Mode must be 'threshold' or 'race'"
  end

  test "threshold mode with zero pace returns error" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Threshold pace must be positive"
  end

  test "threshold mode over 15:00/km returns error" do
    result = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 901).call
    refute result[:valid]
    assert_includes result[:errors], "Threshold pace seems too slow (max 15:00 /km)"
  end

  test "race mode with invalid distance returns error" do
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "100k", race_time_seconds: 1500
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Race distance must be 5k, 10k, half_marathon, or marathon"
  end

  test "race mode with zero time returns error" do
    result = Health::RunningPaceZoneCalculator.new(
      mode: "race", race_distance: "5k", race_time_seconds: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Race time must be positive"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::RunningPaceZoneCalculator.new(mode: "threshold", threshold_pace_seconds: 300)
    assert_equal [], calc.errors
  end
end
