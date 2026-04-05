require "test_helper"

class Health::StepsPerMileCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: miles ---

  test "4200 steps, 2 miles = 2100 steps per mile" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2100, result[:steps_per_mile]
  end

  test "10000 steps, 5 miles = 2000 steps per mile" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 10_000, distance: 5, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2000, result[:steps_per_mile]
  end

  # --- Happy path: km ---

  test "3200 steps, 2 km converted to steps per mile" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 3200, distance: 2, unit: "km"
    ).call

    assert result[:valid]
    # distance_miles = 2 / 1.60934 = 1.2427
    # steps_per_mile = 3200 / 1.2427 = 2574.8
    assert_in_delta 2575, result[:steps_per_mile], 2
  end

  test "steps per km with km input" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 3200, distance: 2, unit: "km"
    ).call

    assert result[:valid]
    assert_equal 1600, result[:steps_per_km]
  end

  # --- Steps per km from miles input ---

  test "steps per km from miles input" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    # distance_km = 2 * 1.60934 = 3.21868
    # steps_per_km = 4200 / 3.21868 = 1304.8
    assert_in_delta 1305, result[:steps_per_km], 2
  end

  # --- Estimated calories ---

  test "calories burned estimate" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 10_000, distance: 5, unit: "miles"
    ).call

    assert result[:valid]
    # 10000 * 0.04 = 400
    assert_equal 400, result[:estimated_calories]
  end

  # --- Stride length ---

  test "stride length calculated in feet" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    # steps_per_mile = 2100
    # stride_ft = 5280 / 2100 = 2.514
    assert_in_delta 2.51, result[:stride_length_ft], 0.02
  end

  test "stride length calculated in meters" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    # stride_ft = 5280 / 2100 = 2.514
    # stride_m = 2.514 * 0.3048 = 0.766
    assert_in_delta 0.77, result[:stride_length_m], 0.02
  end

  # --- Distance conversions ---

  test "distance miles and km are returned" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2.0, result[:distance_miles]
    assert_in_delta 3.22, result[:distance_km], 0.01
  end

  test "total steps is returned" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 4200, result[:total_steps]
  end

  # --- Default unit ---

  test "default unit is miles" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2
    ).call

    assert result[:valid]
    assert_equal 2100, result[:steps_per_mile]
  end

  # --- Validation errors ---

  test "zero steps returns error" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 0, distance: 2, unit: "miles"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total steps must be positive"
  end

  test "negative steps returns error" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: -100, distance: 2, unit: "miles"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total steps must be positive"
  end

  test "zero distance returns error" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 0, unit: "miles"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "negative distance returns error" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: -2, unit: "miles"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "invalid unit returns error" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2, unit: "meters"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Unit must be miles or km"
  end

  # --- Multiple errors ---

  test "multiple validation errors at once" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 0, distance: 0, unit: "invalid"
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: "4200", distance: "2", unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2100, result[:steps_per_mile]
  end

  # --- Edge cases ---

  test "very large step count" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 50_000, distance: 25, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2000, result[:steps_per_mile]
    assert result[:estimated_calories] > 0
  end

  test "very short distance" do
    result = Health::StepsPerMileCalculator.new(
      total_steps: 200, distance: 0.1, unit: "miles"
    ).call

    assert result[:valid]
    assert_equal 2000, result[:steps_per_mile]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::StepsPerMileCalculator.new(
      total_steps: 4200, distance: 2
    )
    assert_equal [], calc.errors
  end
end
