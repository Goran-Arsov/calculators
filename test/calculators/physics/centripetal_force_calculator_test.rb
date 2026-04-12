require "test_helper"

class Physics::CentripetalForceCalculatorTest < ActiveSupport::TestCase
  test "find_force: F = mv^2/r" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 10, velocity: 5, radius: 2
    ).call
    assert result[:valid]
    # F = 10 * 25 / 2 = 125
    assert_in_delta 125.0, result[:force_n], 0.01
  end

  test "find_mass: m = Fr/v^2" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_mass", force: 125, velocity: 5, radius: 2
    ).call
    assert result[:valid]
    assert_in_delta 10.0, result[:mass_kg], 0.01
  end

  test "find_velocity: v = sqrt(Fr/m)" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_velocity", force: 125, mass: 10, radius: 2
    ).call
    assert result[:valid]
    assert_in_delta 5.0, result[:velocity_m_s], 0.01
  end

  test "find_radius: r = mv^2/F" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_radius", force: 125, mass: 10, velocity: 5
    ).call
    assert result[:valid]
    assert_in_delta 2.0, result[:radius_m], 0.01
  end

  test "centripetal acceleration a = v^2/r" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 10, velocity: 5, radius: 2
    ).call
    assert result[:valid]
    assert_in_delta 12.5, result[:centripetal_acceleration_m_s2], 0.01
  end

  test "angular velocity omega = v/r" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 10, velocity: 5, radius: 2
    ).call
    assert result[:valid]
    assert_in_delta 2.5, result[:angular_velocity_rad_s], 0.01
  end

  test "period T = 2*pi*r/v" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 10, velocity: 5, radius: 2
    ).call
    assert result[:valid]
    expected = 2.0 * Math::PI * 2.0 / 5.0
    assert_in_delta expected, result[:period_s], 0.01
  end

  test "zero mass returns error" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 0, velocity: 5, radius: 2
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be a positive number"
  end

  test "negative radius returns error" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: 10, velocity: 5, radius: -2
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Radius must be a positive number"
  end

  test "invalid mode returns error" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "invalid", mass: 10, velocity: 5, radius: 2
    ).call
    refute result[:valid]
  end

  test "string coercion" do
    result = Physics::CentripetalForceCalculator.new(
      mode: "find_force", mass: "10", velocity: "5", radius: "2"
    ).call
    assert result[:valid]
    assert_in_delta 125.0, result[:force_n], 0.01
  end
end
