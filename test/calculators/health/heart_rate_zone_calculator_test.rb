require "test_helper"

class Health::HeartRateZoneCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: age 30, resting HR 70 ---

  test "happy path age 30 resting hr 70" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 70).call
    assert result[:valid]
    # Max HR (Tanaka): 208 - 0.7 * 30 = 187
    assert_equal 187, result[:max_hr]
    # HRR = 187 - 70 = 117
    assert_equal 117, result[:heart_rate_reserve]
    assert_equal 5, result[:zones].length
  end

  # --- Zone calculations ---

  test "zone 1 uses 50-60 percent of hrr" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 70).call
    zone1 = result[:zones].find { |z| z[:key] == :zone_1 }
    # Min: 70 + 117 * 0.50 = 128.5 => 129
    # Max: 70 + 117 * 0.60 = 140.2 => 140
    assert_equal 129, zone1[:min_bpm]
    assert_equal 140, zone1[:max_bpm]
    assert_equal "Warm Up / Recovery", zone1[:name]
  end

  test "zone 5 uses 90-100 percent of hrr" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 70).call
    zone5 = result[:zones].find { |z| z[:key] == :zone_5 }
    # Min: 70 + 117 * 0.90 = 175.3 => 175
    # Max: 70 + 117 * 1.00 = 187
    assert_equal 175, zone5[:min_bpm]
    assert_equal 187, zone5[:max_bpm]
    assert_equal "VO2 Max / Peak", zone5[:name]
  end

  # --- Different ages ---

  test "older person has lower max hr" do
    result_30 = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 70).call
    result_50 = Health::HeartRateZoneCalculator.new(age: 50, resting_hr: 70).call
    assert result_30[:max_hr] > result_50[:max_hr]
    # Max HR at 50: 208 - 0.7 * 50 = 173
    assert_equal 173, result_50[:max_hr]
  end

  test "young person age 20" do
    result = Health::HeartRateZoneCalculator.new(age: 20, resting_hr: 60).call
    assert result[:valid]
    # Max HR: 208 - 0.7 * 20 = 194
    assert_equal 194, result[:max_hr]
    assert_equal 134, result[:heart_rate_reserve]
  end

  # --- Athletic resting HR ---

  test "low resting hr athlete" do
    result = Health::HeartRateZoneCalculator.new(age: 25, resting_hr: 45).call
    assert result[:valid]
    # Max HR: 208 - 0.7 * 25 = 190.5 => 191
    assert_equal 191, result[:max_hr]
    assert_equal 146, result[:heart_rate_reserve]
  end

  # --- Validation: zero/negative age ---

  test "zero age returns error" do
    result = Health::HeartRateZoneCalculator.new(age: 0, resting_hr: 70).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "negative age returns error" do
    result = Health::HeartRateZoneCalculator.new(age: -5, resting_hr: 70).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "age over 120 returns error" do
    result = Health::HeartRateZoneCalculator.new(age: 150, resting_hr: 70).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be realistic (1-120)"
  end

  # --- Validation: resting HR ---

  test "zero resting hr returns error" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Resting heart rate must be positive"
  end

  test "resting hr below 30 returns error" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 25).call
    refute result[:valid]
    assert_includes result[:errors], "Resting heart rate must be realistic (30-120 bpm)"
  end

  test "resting hr above 120 returns error" do
    result = Health::HeartRateZoneCalculator.new(age: 30, resting_hr: 130).call
    refute result[:valid]
    assert_includes result[:errors], "Resting heart rate must be realistic (30-120 bpm)"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::HeartRateZoneCalculator.new(age: "30", resting_hr: "70").call
    assert result[:valid]
    assert_equal 187, result[:max_hr]
  end

  # --- Default resting hr ---

  test "default resting hr is 70" do
    result = Health::HeartRateZoneCalculator.new(age: 30).call
    assert result[:valid]
    assert_equal 70, result[:resting_hr]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::HeartRateZoneCalculator.new(age: 30)
    assert_equal [], calc.errors
  end
end
