require "test_helper"

class Automotive::ZeroToSixtyCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: typical sports car" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 400, curb_weight_lbs: 3500
    ).call
    assert result[:valid]
    assert result[:zero_to_sixty_seconds] > 0
    assert result[:zero_to_sixty_seconds] < 10
    assert result[:quarter_mile_seconds] > result[:zero_to_sixty_seconds]
    assert result[:quarter_mile_mph] > 0
    assert_in_delta 8.75, result[:power_to_weight_ratio], 0.01
  end

  # --- AWD improves time ---

  test "AWD is faster than RWD" do
    rwd = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, drivetrain: "rwd"
    ).call
    awd = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, drivetrain: "awd"
    ).call
    assert rwd[:valid] && awd[:valid]
    assert awd[:zero_to_sixty_seconds] < rwd[:zero_to_sixty_seconds]
  end

  # --- FWD is slower ---

  test "FWD is slower than RWD" do
    rwd = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 200, curb_weight_lbs: 3000, drivetrain: "rwd"
    ).call
    fwd = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 200, curb_weight_lbs: 3000, drivetrain: "fwd"
    ).call
    assert rwd[:valid] && fwd[:valid]
    assert fwd[:zero_to_sixty_seconds] > rwd[:zero_to_sixty_seconds]
  end

  # --- Performance tires improve time ---

  test "performance tires are faster than all-season" do
    stock = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, tire_type: "all_season"
    ).call
    perf = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, tire_type: "performance"
    ).call
    assert stock[:valid] && perf[:valid]
    assert perf[:zero_to_sixty_seconds] < stock[:zero_to_sixty_seconds]
  end

  # --- Validation errors ---

  test "zero horsepower returns error" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 0, curb_weight_lbs: 3500
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Horsepower must be positive"
  end

  test "zero weight returns error" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Curb weight must be positive"
  end

  test "invalid drivetrain returns error" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, drivetrain: "4wd"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Drivetrain must be rwd, fwd, or awd"
  end

  test "invalid tire type returns error" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: 300, curb_weight_lbs: 3500, tire_type: "racing"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Tire type must be all_season, summer, performance, or winter"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::ZeroToSixtyCalculator.new(
      horsepower: "400", curb_weight_lbs: "3500"
    ).call
    assert result[:valid]
  end
end
