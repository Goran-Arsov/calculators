require "test_helper"

class Physics::KineticEnergyCalculatorTest < ActiveSupport::TestCase
  # --- Solve for energy ---

  test "energy: mass=10, velocity=5" do
    result = Physics::KineticEnergyCalculator.new(mass: 10, velocity: 5).call
    assert result[:valid]
    assert_equal 125.0, result[:energy]
    assert_equal :energy, result[:solved_for]
  end

  test "energy: zero velocity yields zero energy" do
    result = Physics::KineticEnergyCalculator.new(mass: 10, velocity: 0).call
    assert result[:valid]
    assert_equal 0.0, result[:energy]
  end

  # --- Solve for mass ---

  test "mass: energy=200, velocity=10" do
    result = Physics::KineticEnergyCalculator.new(energy: 200, velocity: 10).call
    assert result[:valid]
    assert_equal 4.0, result[:mass]
    assert_equal :mass, result[:solved_for]
  end

  # --- Solve for velocity ---

  test "velocity: energy=125, mass=10" do
    result = Physics::KineticEnergyCalculator.new(energy: 125, mass: 10).call
    assert result[:valid]
    assert_equal 5.0, result[:velocity]
    assert_equal :velocity, result[:solved_for]
  end

  test "velocity: zero energy yields zero velocity" do
    result = Physics::KineticEnergyCalculator.new(energy: 0, mass: 10).call
    assert result[:valid]
    assert_equal 0.0, result[:velocity]
  end

  # --- Validation ---

  test "only one value returns error" do
    result = Physics::KineticEnergyCalculator.new(mass: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least two values"
  end

  test "negative energy returns error" do
    result = Physics::KineticEnergyCalculator.new(energy: -50, mass: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Energy must be non-negative"
  end

  test "zero mass returns error" do
    result = Physics::KineticEnergyCalculator.new(mass: 0, velocity: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::KineticEnergyCalculator.new(mass: 10, velocity: 5)
    assert_equal [], calc.errors
  end
end
