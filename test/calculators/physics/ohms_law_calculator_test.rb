require "test_helper"

class Physics::OhmsLawCalculatorTest < ActiveSupport::TestCase
  # --- Solve for voltage ---

  test "voltage: current=2, resistance=5" do
    result = Physics::OhmsLawCalculator.new(current: 2, resistance: 5).call
    assert result[:valid]
    assert_equal 10.0, result[:voltage]
    assert_equal 20.0, result[:power]
    assert_equal :voltage, result[:solved_for]
  end

  # --- Solve for current ---

  test "current: voltage=12, resistance=4" do
    result = Physics::OhmsLawCalculator.new(voltage: 12, resistance: 4).call
    assert result[:valid]
    assert_equal 3.0, result[:current]
    assert_equal 36.0, result[:power]
    assert_equal :current, result[:solved_for]
  end

  # --- Solve for resistance ---

  test "resistance: voltage=10, current=2" do
    result = Physics::OhmsLawCalculator.new(voltage: 10, current: 2).call
    assert result[:valid]
    assert_equal 5.0, result[:resistance]
    assert_equal 20.0, result[:power]
    assert_equal :resistance, result[:solved_for]
  end

  # --- Consistency ---

  test "all three modes produce consistent results" do
    r1 = Physics::OhmsLawCalculator.new(current: 3, resistance: 4).call
    r2 = Physics::OhmsLawCalculator.new(voltage: 12, resistance: 4).call
    r3 = Physics::OhmsLawCalculator.new(voltage: 12, current: 3).call

    assert_equal r1[:voltage], r2[:voltage]
    assert_equal r1[:current], r3[:current]
    assert_equal r2[:resistance], r3[:resistance]
  end

  # --- Validation ---

  test "only one value returns error" do
    result = Physics::OhmsLawCalculator.new(voltage: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Provide at least two values"
  end

  test "negative resistance returns error" do
    result = Physics::OhmsLawCalculator.new(resistance: -5, current: 2).call
    refute result[:valid]
    assert_includes result[:errors], "Resistance must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::OhmsLawCalculator.new(voltage: 10, current: 2)
    assert_equal [], calc.errors
  end
end
