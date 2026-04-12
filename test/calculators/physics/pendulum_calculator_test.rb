require "test_helper"

class Physics::PendulumCalculatorTest < ActiveSupport::TestCase
  test "find_period: 1m pendulum on Earth" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 1.0
    ).call
    assert result[:valid]
    expected = 2.0 * Math::PI * Math.sqrt(1.0 / 9.80665)
    assert_in_delta expected, result[:period_s], 0.0001
  end

  test "find_period: frequency is 1/T" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 1.0
    ).call
    assert result[:valid]
    assert_in_delta(1.0 / result[:period_s], result[:frequency_hz], 0.0001)
  end

  test "find_period: custom gravity (Moon)" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 1.0, gravity: 1.62
    ).call
    assert result[:valid]
    expected = 2.0 * Math::PI * Math.sqrt(1.0 / 1.62)
    assert_in_delta expected, result[:period_s], 0.001
  end

  test "find_length: from period" do
    result = Physics::PendulumCalculator.new(
      mode: "find_length", period: 2.0
    ).call
    assert result[:valid]
    # L = g*(T/(2*pi))^2
    expected = 9.80665 * (2.0 / (2 * Math::PI))**2
    assert_in_delta expected, result[:length_m], 0.001
  end

  test "find_gravity: from length and period" do
    result = Physics::PendulumCalculator.new(
      mode: "find_gravity", length: 1.0, period: 2.006
    ).call
    assert result[:valid]
    # g should be close to 9.81
    assert_in_delta 9.81, result[:gravity_m_s2], 0.1
  end

  test "angular frequency is 2*pi*f" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 0.5
    ).call
    assert result[:valid]
    assert_in_delta(2.0 * Math::PI * result[:frequency_hz], result[:angular_frequency_rad_s], 0.001)
  end

  test "zero length returns error" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Length must be a positive number"
  end

  test "negative gravity returns error" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: 1.0, gravity: -5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gravity must be a positive number"
  end

  test "missing period for find_length returns error" do
    result = Physics::PendulumCalculator.new(
      mode: "find_length"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Period is required"
  end

  test "invalid mode returns error" do
    result = Physics::PendulumCalculator.new(mode: "invalid").call
    refute result[:valid]
  end

  test "string coercion" do
    result = Physics::PendulumCalculator.new(
      mode: "find_period", length: "1.0"
    ).call
    assert result[:valid]
  end
end
