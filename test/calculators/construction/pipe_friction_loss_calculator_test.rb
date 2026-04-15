require "test_helper"

class Construction::PipeFrictionLossCalculatorTest < ActiveSupport::TestCase
  test "10 gpm in 1 in PVC over 100 ft" do
    result = Construction::PipeFrictionLossCalculator.new(
      flow_gpm: 10, diameter_in: 1.0, length_ft: 100, material: "pvc"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:head_loss_ft] > 0
    assert result[:pressure_loss_psi] > 0
    assert_equal 150, result[:c_factor]
  end

  test "smoother pipe loses less pressure" do
    pvc = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100, material: "pvc").call
    galv = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100, material: "galvanized").call
    assert pvc[:pressure_loss_psi] < galv[:pressure_loss_psi]
  end

  test "larger diameter reduces loss dramatically" do
    small = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 0.5, length_ft: 100).call
    large = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1.5, length_ft: 100).call
    assert large[:pressure_loss_psi] < small[:pressure_loss_psi] / 10
  end

  test "velocity calculation" do
    result = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100).call
    # v = 0.4085 × 10 / 1² = 4.085
    assert_in_delta 4.09, result[:velocity_fps], 0.01
    assert result[:velocity_ok]
  end

  test "high velocity flagged as not ok" do
    result = Construction::PipeFrictionLossCalculator.new(flow_gpm: 30, diameter_in: 0.75, length_ft: 100).call
    # v = 0.4085 × 30 / 0.5625 ≈ 21.8 — way above 8 fps
    assert_equal false, result[:velocity_ok]
  end

  test "loss scales linearly with length" do
    r50 = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 50).call
    r100 = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100).call
    assert_in_delta r50[:pressure_loss_psi] * 2, r100[:pressure_loss_psi], 0.01
  end

  test "error when flow is zero" do
    result = Construction::PipeFrictionLossCalculator.new(flow_gpm: 0, diameter_in: 1, length_ft: 100).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Flow must be greater than zero"
  end

  test "error for unknown material" do
    result = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100, material: "gold").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Material must be") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PipeFrictionLossCalculator.new(flow_gpm: 10, diameter_in: 1, length_ft: 100)
    assert_equal [], calc.errors
  end
end
