require "test_helper"

class Construction::CaulkCalculatorTest < ActiveSupport::TestCase
  test "30 ft of 1/4 in × 1/4 in joint" do
    result = Construction::CaulkCalculator.new(
      length_ft: 30, joint_width_in: 0.25, joint_depth_in: 0.25, tube_size: "10.1", waste_pct: 0
    ).call
    assert_equal true, result[:valid]
    # Joint: 360 in × 0.0625 sq in = 22.5 cu in
    assert_in_delta 22.5, result[:joint_volume_cuin], 0.01
    # Tube: 10.1 × 1.80469 = 18.23 cu in
    assert_in_delta 18.23, result[:tube_volume_cuin], 0.01
    # Tubes: 22.5 / 18.23 ≈ 1.23 → 2 tubes
    assert_equal 2, result[:tubes_with_waste]
  end

  test "waste rounds up tubes" do
    no_waste = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.25, joint_depth_in: 0.25, waste_pct: 0).call
    with_waste = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.25, joint_depth_in: 0.25, waste_pct: 20).call
    assert with_waste[:tubes_with_waste] >= no_waste[:tubes_with_waste]
  end

  test "larger joint needs more caulk" do
    small = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.125, joint_depth_in: 0.125).call
    large = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.5, joint_depth_in: 0.5).call
    assert large[:tubes_with_waste] > small[:tubes_with_waste]
  end

  test "larger tube covers more linear feet" do
    r10 = Construction::CaulkCalculator.new(length_ft: 100, joint_width_in: 0.25, joint_depth_in: 0.25, tube_size: "10.1").call
    r28 = Construction::CaulkCalculator.new(length_ft: 100, joint_width_in: 0.25, joint_depth_in: 0.25, tube_size: "28").call
    assert r28[:linear_ft_per_tube] > r10[:linear_ft_per_tube]
  end

  test "linear feet per tube" do
    result = Construction::CaulkCalculator.new(length_ft: 100, joint_width_in: 0.25, joint_depth_in: 0.25, tube_size: "10.1").call
    # tube 18.23 cu in / (0.25 × 0.25) = 291.6 in = 24.3 ft
    assert_in_delta 24.3, result[:linear_ft_per_tube], 0.1
  end

  test "error when length is zero" do
    result = Construction::CaulkCalculator.new(length_ft: 0, joint_width_in: 0.25, joint_depth_in: 0.25).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error for invalid tube size" do
    result = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.25, joint_depth_in: 0.25, tube_size: "5").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Tube size must be 10.1, 20, or 28"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::CaulkCalculator.new(length_ft: 30, joint_width_in: 0.25, joint_depth_in: 0.25)
    assert_equal [], calc.errors
  end
end
