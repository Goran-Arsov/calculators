require "test_helper"

class Physics::VelocityCalculatorTest < ActiveSupport::TestCase
  # --- Solve for velocity ---

  test "velocity: distance=100, time=10" do
    result = Physics::VelocityCalculator.new(distance: 100, time: 10).call
    assert result[:valid]
    assert_equal 10.0, result[:velocity]
    assert_equal :velocity, result[:solved_for]
  end

  test "velocity: fractional values" do
    result = Physics::VelocityCalculator.new(distance: 7.5, time: 2.5).call
    assert result[:valid]
    assert_equal 3.0, result[:velocity]
  end

  # --- Solve for distance ---

  test "distance: velocity=10, time=5" do
    result = Physics::VelocityCalculator.new(velocity: 10, time: 5).call
    assert result[:valid]
    assert_equal 50.0, result[:distance]
    assert_equal :distance, result[:solved_for]
  end

  # --- Solve for time ---

  test "time: distance=100, velocity=20" do
    result = Physics::VelocityCalculator.new(distance: 100, velocity: 20).call
    assert result[:valid]
    assert_equal 5.0, result[:time]
    assert_equal :time, result[:solved_for]
  end

  # --- Validation ---

  test "only one value returns error" do
    result = Physics::VelocityCalculator.new(distance: 100).call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least two values"
  end

  test "no values returns error" do
    result = Physics::VelocityCalculator.new.call
    refute result[:valid]
  end

  test "negative distance returns error" do
    result = Physics::VelocityCalculator.new(distance: -10, time: 5).call
    refute result[:valid]
    assert_includes result[:errors], "Distance must be positive"
  end

  test "zero time returns error" do
    result = Physics::VelocityCalculator.new(distance: 100, time: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Time must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::VelocityCalculator.new(distance: 10, time: 2)
    assert_equal [], calc.errors
  end
end
