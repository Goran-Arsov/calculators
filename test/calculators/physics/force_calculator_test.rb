require "test_helper"

class Physics::ForceCalculatorTest < ActiveSupport::TestCase
  # --- Solve for force ---

  test "force: mass=10, acceleration=5" do
    result = Physics::ForceCalculator.new(mass: 10, acceleration: 5).call
    assert result[:valid]
    assert_equal 50.0, result[:force]
    assert_equal :force, result[:solved_for]
  end

  test "force: zero acceleration is valid" do
    result = Physics::ForceCalculator.new(mass: 10, acceleration: 0).call
    assert result[:valid]
    assert_equal 0.0, result[:force]
  end

  # --- Solve for mass ---

  test "mass: force=100, acceleration=10" do
    result = Physics::ForceCalculator.new(force: 100, acceleration: 10).call
    assert result[:valid]
    assert_equal 10.0, result[:mass]
    assert_equal :mass, result[:solved_for]
  end

  # --- Solve for acceleration ---

  test "acceleration: force=50, mass=10" do
    result = Physics::ForceCalculator.new(force: 50, mass: 10).call
    assert result[:valid]
    assert_equal 5.0, result[:acceleration]
    assert_equal :acceleration, result[:solved_for]
  end

  test "acceleration: negative force yields negative acceleration" do
    result = Physics::ForceCalculator.new(force: -20, mass: 5).call
    assert result[:valid]
    assert_equal(-4.0, result[:acceleration])
  end

  # --- Validation ---

  test "only one value returns error" do
    result = Physics::ForceCalculator.new(mass: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least two values"
  end

  test "negative mass returns error" do
    result = Physics::ForceCalculator.new(mass: -5, acceleration: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::ForceCalculator.new(mass: 10, acceleration: 5)
    assert_equal [], calc.errors
  end
end
