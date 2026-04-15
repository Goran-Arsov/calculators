require "test_helper"

class Construction::RoofPitchCalculatorTest < ActiveSupport::TestCase
  test "rise_run mode computes 6/12 pitch" do
    result = Construction::RoofPitchCalculator.new(mode: "rise_run", rise_in: 6, run_in: 12).call
    assert_equal true, result[:valid]
    assert_in_delta 6.0, result[:pitch_x_per_12], 0.01
    assert_in_delta 26.57, result[:angle_deg], 0.01
    assert_in_delta 50.0, result[:grade_pct], 0.01
  end

  test "angle mode converts 45 degrees to 12/12" do
    result = Construction::RoofPitchCalculator.new(mode: "angle", angle_deg: 45).call
    assert_equal true, result[:valid]
    assert_in_delta 12.0, result[:pitch_x_per_12], 0.01
  end

  test "grade mode converts 50% to 6/12" do
    result = Construction::RoofPitchCalculator.new(mode: "grade", grade_pct: 50).call
    assert_equal true, result[:valid]
    assert_in_delta 6.0, result[:pitch_x_per_12], 0.01
  end

  test "slope category for flat roof" do
    result = Construction::RoofPitchCalculator.new(mode: "rise_run", rise_in: 1, run_in: 12).call
    assert_equal "Flat (membrane required)", result[:slope_category]
  end

  test "slope category for conventional" do
    result = Construction::RoofPitchCalculator.new(mode: "rise_run", rise_in: 6, run_in: 12).call
    assert_equal "Conventional slope", result[:slope_category]
  end

  test "slope category for steep" do
    result = Construction::RoofPitchCalculator.new(mode: "rise_run", rise_in: 10, run_in: 12).call
    assert_equal "Steep slope", result[:slope_category]
  end

  test "error when rise_run mode missing rise" do
    result = Construction::RoofPitchCalculator.new(mode: "rise_run", run_in: 12).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Rise must be greater than zero"
  end

  test "error when angle is out of range" do
    result = Construction::RoofPitchCalculator.new(mode: "angle", angle_deg: 95).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Angle must be between 0 and 90 degrees"
  end

  test "error when mode is invalid" do
    result = Construction::RoofPitchCalculator.new(mode: "bogus").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Mode must be rise_run, angle, or grade"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RoofPitchCalculator.new(mode: "rise_run", rise_in: 6, run_in: 12)
    assert_equal [], calc.errors
  end
end
