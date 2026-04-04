require "test_helper"

class Physics::ElementVolumeCalculatorTest < ActiveSupport::TestCase
  # --- Happy paths ---

  test "iron: density 7.874 g/cm³" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Fe", mass: 7.874).call
    assert result[:valid]
    assert_equal "Iron", result[:element]
    assert_in_delta 1.0, result[:volume], 0.001
  end

  test "gold: 1000 g" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Au", mass: 1000).call
    assert result[:valid]
    expected = (1000.0 / 19.282).round(6)
    assert_in_delta expected, result[:volume], 0.001
  end

  test "aluminium: lightweight metal" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Al", mass: 100).call
    assert result[:valid]
    expected = (100.0 / 2.699).round(6)
    assert_in_delta expected, result[:volume], 0.001
  end

  test "returns element name, symbol, and density" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Pb", mass: 50).call
    assert result[:valid]
    assert_equal "Lead", result[:element]
    assert_equal "Pb", result[:symbol]
    assert_equal 11.342, result[:density]
  end

  # --- Consistency with mass calculator ---

  test "mass and volume calculators are consistent" do
    mass_result = Physics::ElementMassCalculator.new(symbol: "Cu", volume: 5).call
    vol_result = Physics::ElementVolumeCalculator.new(symbol: "Cu", mass: mass_result[:mass]).call
    assert_in_delta 5.0, vol_result[:volume], 0.001
  end

  # --- Validation ---

  test "unknown symbol returns error" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Zz", mass: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Unknown element symbol: Zz"
  end

  test "element with nil density returns error" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Og", mass: 10).call
    refute result[:valid]
    assert_includes result[:errors], "No known density for Oganesson"
  end

  test "zero mass returns error" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Fe", mass: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be positive"
  end

  test "negative mass returns error" do
    result = Physics::ElementVolumeCalculator.new(symbol: "Fe", mass: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Mass must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Physics::ElementVolumeCalculator.new(symbol: "Fe", mass: 10)
    assert_equal [], calc.errors
  end
end
