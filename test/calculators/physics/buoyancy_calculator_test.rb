require "test_helper"

class Physics::BuoyancyCalculatorTest < ActiveSupport::TestCase
  test "object less dense than water floats" do
    # Wood: mass=0.5kg, volume=0.001m^3 => density=500 kg/m^3 < 998
    result = Physics::BuoyancyCalculator.new(
      object_mass: 0.5, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    assert_equal "Floats", result[:status]
  end

  test "buoyant force calculation" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 1.0, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    # Fb = 998 * 0.001 * 9.80665 = 9.787
    assert_in_delta 9.787, result[:buoyant_force_n], 0.01
  end

  test "steel sinks in water" do
    # Steel: mass=7.8kg, volume=0.001m^3 => density=7800 kg/m^3 > 998
    result = Physics::BuoyancyCalculator.new(
      object_mass: 7.8, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    assert_equal "Sinks", result[:status]
  end

  test "object density matches fluid is neutrally buoyant" do
    # Density = 998 kg/m^3
    result = Physics::BuoyancyCalculator.new(
      object_mass: 0.998, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    assert_equal "Neutrally buoyant", result[:status]
  end

  test "apparent weight when sinking" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 5.0, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    expected_apparent = (5.0 * 9.80665) - (998.0 * 0.001 * 9.80665)
    assert_in_delta expected_apparent, result[:apparent_weight_n], 0.01
  end

  test "apparent weight is zero when floating" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 0.5, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    assert_in_delta 0.0, result[:apparent_weight_n], 0.01
  end

  test "percent submerged for floating object" do
    # density=500, fluid=998 => 50.1% submerged
    result = Physics::BuoyancyCalculator.new(
      object_mass: 0.5, object_volume: 0.001, fluid: "water"
    ).call
    assert result[:valid]
    assert_in_delta 50.1, result[:percent_submerged], 0.5
  end

  test "custom fluid density" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 1.0, object_volume: 0.001, fluid: "custom", custom_fluid_density: 1500
    ).call
    assert result[:valid]
    expected_fb = 1500.0 * 0.001 * 9.80665
    assert_in_delta expected_fb, result[:buoyant_force_n], 0.01
  end

  test "seawater fluid" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 1.0, object_volume: 0.001, fluid: "seawater"
    ).call
    assert result[:valid]
    assert_equal "Seawater", result[:fluid_name]
  end

  test "zero mass returns error" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 0, object_volume: 0.001, fluid: "water"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Object mass must be a positive number"
  end

  test "zero volume returns error" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 1.0, object_volume: 0, fluid: "water"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Object volume must be a positive number"
  end

  test "unknown fluid returns error" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: 1.0, object_volume: 0.001, fluid: "lava"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Unknown fluid: lava"
  end

  test "string coercion" do
    result = Physics::BuoyancyCalculator.new(
      object_mass: "1.0", object_volume: "0.001", fluid: "water"
    ).call
    assert result[:valid]
  end
end
