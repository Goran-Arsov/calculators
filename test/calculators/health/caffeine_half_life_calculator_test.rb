require "test_helper"

class Health::CaffeineHalfLifeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: basic decay ---

  test "95mg after 5 hours is approximately 47.5mg" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 95, hours_elapsed: 5).call
    assert result[:valid]
    assert_in_delta 47.5, result[:remaining_after_hours], 0.5
    assert_in_delta 50.0, result[:percent_remaining], 0.5
  end

  test "95mg after 10 hours is approximately 23.75mg" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 95, hours_elapsed: 10).call
    assert result[:valid]
    assert_in_delta 23.75, result[:remaining_after_hours], 0.5
  end

  test "200mg after 0 hours is 200mg" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 200, hours_elapsed: 0).call
    assert result[:valid]
    assert_in_delta 200.0, result[:remaining_after_hours], 0.1
  end

  # --- Sleep-safe time ---

  test "95mg has sleep-safe time greater than 0" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 95).call
    assert result[:valid]
    assert result[:hours_until_sleep_safe] > 0
  end

  test "40mg is already below sleep threshold" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 40).call
    assert result[:valid]
    assert_equal 0.0, result[:hours_until_sleep_safe]
  end

  test "200mg sleep-safe hours calculation" do
    # hours = 5 * log2(200/50) = 5 * 2 = 10
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 200).call
    assert result[:valid]
    assert_in_delta 10.0, result[:hours_until_sleep_safe], 0.1
  end

  # --- Timeline ---

  test "timeline has 25 entries for 0-24 hours" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 100).call
    assert result[:valid]
    assert_equal 25, result[:timeline].length
    assert_equal 0, result[:timeline].first[:hours]
    assert_equal 24, result[:timeline].last[:hours]
  end

  test "timeline values decrease over time" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 100).call
    values = result[:timeline].map { |t| t[:caffeine_mg] }
    values.each_cons(2) { |a, b| assert a >= b }
  end

  # --- With consumed_at and sleep_time ---

  test "caffeine at bedtime is calculated" do
    result = Health::CaffeineHalfLifeCalculator.new(
      caffeine_mg: 200, consumed_at: "08:00", sleep_time: "22:00"
    ).call
    assert result[:valid]
    assert result[:caffeine_at_bedtime] > 0
    assert_equal 14.0, result[:hours_to_sleep]
  end

  test "sleep-safe time formatted when consumed_at provided" do
    result = Health::CaffeineHalfLifeCalculator.new(
      caffeine_mg: 200, consumed_at: "08:00"
    ).call
    assert result[:valid]
    assert result[:sleep_safe_time].match?(/\A\d{2}:\d{2}\z/)
  end

  # --- Sleep impact labels ---

  test "high caffeine at bedtime shows high impact" do
    result = Health::CaffeineHalfLifeCalculator.new(
      caffeine_mg: 400, consumed_at: "18:00", sleep_time: "22:00"
    ).call
    assert result[:valid]
    assert_includes result[:sleep_impact], "High"
  end

  # --- Validation ---

  test "zero caffeine returns error" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Caffeine amount must be positive"
  end

  test "negative caffeine returns error" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Caffeine amount must be positive"
  end

  test "caffeine over 2000 returns error" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 2500).call
    refute result[:valid]
    assert_includes result[:errors], "Caffeine amount seems unrealistically high (max 2000 mg)"
  end

  test "negative hours_elapsed returns error" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 100, hours_elapsed: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Hours elapsed must be zero or positive"
  end

  test "invalid consumed_at format returns error" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 100, consumed_at: "abc").call
    refute result[:valid]
    assert_includes result[:errors], "Consumed-at time must be in HH:MM format"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: "200", hours_elapsed: "5").call
    assert result[:valid]
    assert_in_delta 100.0, result[:remaining_after_hours], 0.5
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::CaffeineHalfLifeCalculator.new(caffeine_mg: 100)
    assert_equal [], calc.errors
  end
end
