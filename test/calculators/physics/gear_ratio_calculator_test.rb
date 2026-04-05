require "test_helper"

class Physics::GearRatioCalculatorTest < ActiveSupport::TestCase
  test "basic 3:1 gear ratio" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 20, driven_teeth: 60).call
    assert result[:valid]
    assert_in_delta 3.0, result[:gear_ratio], 0.0001
    assert_equal "3.0:1", result[:gear_ratio_display]
  end

  test "1:1 direct drive ratio" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 40, driven_teeth: 40).call
    assert result[:valid]
    assert_in_delta 1.0, result[:gear_ratio], 0.0001
  end

  test "overdrive ratio (less than 1)" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 60, driven_teeth: 20).call
    assert result[:valid]
    assert_in_delta 0.3333, result[:gear_ratio], 0.001
    assert_match(/1:/, result[:gear_ratio_display])
    refute result[:speed_reduction]
  end

  test "output speed calculation" do
    result = Physics::GearRatioCalculator.new(
      driving_teeth: 20, driven_teeth: 60, input_speed: 1500
    ).call
    assert result[:valid]
    assert_in_delta 500.0, result[:output_speed_rpm], 0.01
  end

  test "output torque calculation" do
    result = Physics::GearRatioCalculator.new(
      driving_teeth: 20, driven_teeth: 60, input_torque: 10
    ).call
    assert result[:valid]
    assert_in_delta 30.0, result[:output_torque_nm], 0.01
    assert_in_delta 3.0, result[:torque_multiplier], 0.0001
  end

  test "non-integer gear ratio" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 17, driven_teeth: 43).call
    assert result[:valid]
    assert_in_delta 2.5294, result[:gear_ratio], 0.001
  end

  test "speed and torque together" do
    result = Physics::GearRatioCalculator.new(
      driving_teeth: 15, driven_teeth: 45, input_speed: 3000, input_torque: 5
    ).call
    assert result[:valid]
    assert_in_delta 1000.0, result[:output_speed_rpm], 0.01
    assert_in_delta 15.0, result[:output_torque_nm], 0.01
  end

  test "zero driving teeth returns error" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 0, driven_teeth: 60).call
    refute result[:valid]
    assert_includes result[:errors], "Driving gear teeth must be a positive number"
  end

  test "negative driven teeth returns error" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 20, driven_teeth: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Driven gear teeth must be a positive number"
  end

  test "negative input speed returns error" do
    result = Physics::GearRatioCalculator.new(
      driving_teeth: 20, driven_teeth: 60, input_speed: -100
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Input speed must be non-negative"
  end

  test "string coercion for teeth parameters" do
    result = Physics::GearRatioCalculator.new(driving_teeth: "20", driven_teeth: "60").call
    assert result[:valid]
    assert_in_delta 3.0, result[:gear_ratio], 0.0001
  end

  test "large gear values" do
    result = Physics::GearRatioCalculator.new(driving_teeth: 12, driven_teeth: 300).call
    assert result[:valid]
    assert_in_delta 25.0, result[:gear_ratio], 0.0001
  end

  test "errors accessor starts empty" do
    calc = Physics::GearRatioCalculator.new(driving_teeth: 20, driven_teeth: 60)
    assert_equal [], calc.errors
  end
end
