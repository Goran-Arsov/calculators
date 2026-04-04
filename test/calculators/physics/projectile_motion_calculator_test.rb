require "test_helper"

class Physics::ProjectileMotionCalculatorTest < ActiveSupport::TestCase
  G = Physics::ProjectileMotionCalculator::GRAVITY

  # --- Happy path ---

  test "45 degrees at 10 m/s from ground" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 45).call
    assert result[:valid]

    rad = 45 * ::Math::PI / 180
    vx = 10 * ::Math.cos(rad)
    vy = 10 * ::Math.sin(rad)
    expected_time = 2 * vy / G
    expected_range = vx * expected_time

    assert_in_delta expected_range, result[:range], 0.001
    assert_in_delta expected_time, result[:flight_time], 0.001
  end

  test "max height calculation" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 20, angle: 60).call
    assert result[:valid]

    rad = 60 * ::Math::PI / 180
    vy = 20 * ::Math.sin(rad)
    expected_max_height = (vy**2) / (2 * G)

    assert_in_delta expected_max_height, result[:max_height], 0.001
  end

  test "with initial height" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 15, angle: 30, height: 10).call
    assert result[:valid]

    assert result[:max_height] > 10
    assert result[:flight_time] > 0
    assert result[:range] > 0
  end

  test "velocity components are correct" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 30).call
    assert result[:valid]

    rad = 30 * ::Math::PI / 180
    assert_in_delta(10 * ::Math.cos(rad), result[:horizontal_velocity], 0.001)
    assert_in_delta(10 * ::Math.sin(rad), result[:vertical_velocity], 0.001)
  end

  # --- Validation ---

  test "zero velocity returns error" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 0, angle: 45).call
    refute result[:valid]
    assert_includes result[:errors], "Velocity must be positive"
  end

  test "negative velocity returns error" do
    result = Physics::ProjectileMotionCalculator.new(velocity: -10, angle: 45).call
    refute result[:valid]
    assert_includes result[:errors], "Velocity must be positive"
  end

  test "angle of 0 returns error" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Angle must be between 0 and 90 degrees"
  end

  test "angle of 90 returns error" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 90).call
    refute result[:valid]
    assert_includes result[:errors], "Angle must be between 0 and 90 degrees"
  end

  test "negative height returns error" do
    result = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 45, height: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be non-negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::ProjectileMotionCalculator.new(velocity: 10, angle: 45)
    assert_equal [], calc.errors
  end
end
