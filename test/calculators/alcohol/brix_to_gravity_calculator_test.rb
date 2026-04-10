require "test_helper"

class Alcohol::BrixToGravityCalculatorTest < ActiveSupport::TestCase
  test "OG only conversion 14 brix at 1.04 wcf" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 14, wort_correction_factor: 1.04).call
    assert_equal true, result[:valid]
    # Corrected brix = 14/1.04 ≈ 13.46
    assert_in_delta 13.46, result[:og_corrected_brix], 0.05
    # SG ≈ 1.054
    assert_in_delta 1.054, result[:og], 0.001
    assert_nil result[:fg]
  end

  test "OG and FG with terrill cubic" do
    result = Alcohol::BrixToGravityCalculator.new(
      og_brix: 14, fg_brix: 7, wort_correction_factor: 1.04
    ).call
    assert_equal true, result[:valid]
    assert result[:fg].present?
    # FG should be close to 1.012 for 14→7 brix
    assert_in_delta 1.013, result[:fg], 0.005
    assert result[:abv].between?(5.0, 6.5)
  end

  test "FG blank string is treated as nil" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 14, fg_brix: "").call
    assert_equal true, result[:valid]
    assert_nil result[:fg]
  end

  test "wcf default is 1.04" do
    calc = Alcohol::BrixToGravityCalculator.new(og_brix: 14)
    result = calc.call
    assert_equal true, result[:valid]
  end

  test "attenuation is reasonable for typical fermentation" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 14, fg_brix: 7).call
    assert result[:attenuation].between?(60, 90)
  end

  test "error when og brix is zero" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 0).call
    assert_equal false, result[:valid]
  end

  test "error when og brix is too high" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 50).call
    assert_equal false, result[:valid]
  end

  test "error when fg brix exceeds og brix" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 10, fg_brix: 12).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "FG Brix cannot exceed OG Brix"
  end

  test "error when wcf is out of range" do
    result = Alcohol::BrixToGravityCalculator.new(og_brix: 14, wort_correction_factor: 0.5).call
    assert_equal false, result[:valid]
  end
end
