require "test_helper"

class Physics::ElementMassCalculatorTest < ActiveSupport::TestCase
  # --- Happy paths ---

  test "iron: 1 cm³" do
    result = Physics::ElementMassCalculator.new(symbol: "Fe", volume: 1).call
    assert result[:valid]
    assert_equal "Iron", result[:element]
    assert_equal 7.874, result[:mass]
  end

  test "gold: 10 cm³" do
    result = Physics::ElementMassCalculator.new(symbol: "Au", volume: 10).call
    assert result[:valid]
    assert_in_delta 192.82, result[:mass], 0.01
  end

  test "hydrogen gas: large volume" do
    result = Physics::ElementMassCalculator.new(symbol: "H", volume: 1000).call
    assert result[:valid]
    assert_in_delta 0.08988, result[:mass], 0.0001
  end

  test "osmium: densest element" do
    result = Physics::ElementMassCalculator.new(symbol: "Os", volume: 1).call
    assert result[:valid]
    assert_equal 22.587, result[:mass]
  end

  test "returns element name and symbol" do
    result = Physics::ElementMassCalculator.new(symbol: "Cu", volume: 5).call
    assert result[:valid]
    assert_equal "Copper", result[:element]
    assert_equal "Cu", result[:symbol]
    assert_equal 8.96, result[:density]
  end

  # --- Validation ---

  test "unknown symbol returns error" do
    result = Physics::ElementMassCalculator.new(symbol: "Xx", volume: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Unknown element symbol: Xx"
  end

  test "element with nil density returns error" do
    result = Physics::ElementMassCalculator.new(symbol: "Fm", volume: 10).call
    refute result[:valid]
    assert_includes result[:errors], "No known density for Fermium"
  end

  test "zero volume returns error" do
    result = Physics::ElementMassCalculator.new(symbol: "Fe", volume: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Volume must be positive"
  end

  test "negative volume returns error" do
    result = Physics::ElementMassCalculator.new(symbol: "Fe", volume: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Volume must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::ElementMassCalculator.new(symbol: "Fe", volume: 1)
    assert_equal [], calc.errors
  end
end
