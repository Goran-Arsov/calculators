require "test_helper"

class Construction::ConcreteMixCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "3000 PSI at 1 cubic yard produces valid results" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 1
    ).call
    assert_equal true, result[:valid]
    assert_equal 3000, result[:target_psi]
    assert_equal "Standard residential", result[:label]
    assert result[:cement_lbs] > 0
    assert result[:sand_lbs] > 0
    assert result[:gravel_lbs] > 0
    assert result[:water_gallons] > 0
    assert result[:cement_bags_94lb] > 0
  end

  test "3000 PSI has correct ratio" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 3000
    ).call
    assert_equal 1.0, result[:ratio_cement]
    assert_equal 2.0, result[:ratio_sand]
    assert_equal 3.0, result[:ratio_gravel]
    assert_equal 0.55, result[:water_cement_ratio]
  end

  test "5000 PSI has correct ratio" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 5000
    ).call
    assert_equal 1.0, result[:ratio_cement]
    assert_equal 1.0, result[:ratio_sand]
    assert_equal 2.0, result[:ratio_gravel]
    assert_equal 0.35, result[:water_cement_ratio]
  end

  test "higher PSI requires more cement per cubic yard" do
    result_3000 = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 1
    ).call
    result_5000 = Construction::ConcreteMixCalculator.new(
      target_psi: 5000, volume_cubic_yards: 1
    ).call
    assert result_5000[:cement_lbs] > result_3000[:cement_lbs]
  end

  test "doubling volume doubles material quantities" do
    result_1 = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 1
    ).call
    result_2 = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 2
    ).call
    assert_equal result_1[:cement_lbs] * 2, result_2[:cement_lbs]
    assert_equal result_1[:sand_lbs] * 2, result_2[:sand_lbs]
  end

  test "cement bags rounds up" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 1
    ).call
    expected_bags = (result[:cement_lbs] / 94.0).ceil
    assert_equal expected_bags, result[:cement_bags_94lb]
  end

  test "all PSI grades produce valid results" do
    [ 2500, 3000, 3500, 4000, 4500, 5000 ].each do |psi|
      result = Construction::ConcreteMixCalculator.new(
        target_psi: psi, volume_cubic_yards: 1
      ).call
      assert_equal true, result[:valid], "PSI #{psi} should produce valid results"
    end
  end

  # --- Validation errors ---

  test "error when volume is zero" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 3000, volume_cubic_yards: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Volume must be greater than zero"
  end

  test "error when PSI is invalid" do
    result = Construction::ConcreteMixCalculator.new(
      target_psi: 9999, volume_cubic_yards: 1
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Target PSI") }
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ConcreteMixCalculator.new(
      target_psi: 3000
    )
    assert_equal [], calc.errors
  end
end
