require "test_helper"

class Alcohol::DistillerProofingCalculatorTest < ActiveSupport::TestCase
  test "75 percent to 40 percent dilution" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 75, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert_equal true, result[:valid]
    # final = 10 * 75/40 = 18.75 L
    assert_equal 18.75, result[:final_volume_l]
    # water to add = 18.75 - 10 = 8.75 L
    assert_equal 8.75, result[:water_to_add_l]
  end

  test "proof conversion is 2x abv" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 75, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert_equal 150.0, result[:start_proof]
    assert_equal 80.0, result[:target_proof]
  end

  test "milliliter conversion of water" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 60, start_volume_l: 5, target_abv_pct: 40
    ).call
    assert_equal result[:water_to_add_l] * 1000, result[:water_to_add_ml]
  end

  test "gallon conversions" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 75, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert_in_delta 18.75 / 3.78541, result[:final_volume_gal], 0.01
    assert_in_delta 8.75 / 3.78541, result[:water_to_add_gal], 0.01
  end

  test "smaller dilution requires less water" do
    big = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 80, start_volume_l: 10, target_abv_pct: 40
    ).call
    small = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 50, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert small[:water_to_add_l] < big[:water_to_add_l]
  end

  test "error when target equal to start" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 40, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Target ABV must be less than starting ABV"
  end

  test "error when start abv too high" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 99, start_volume_l: 10, target_abv_pct: 40
    ).call
    assert_equal false, result[:valid]
  end

  test "error when start volume zero" do
    result = Alcohol::DistillerProofingCalculator.new(
      start_abv_pct: 75, start_volume_l: 0, target_abv_pct: 40
    ).call
    assert_equal false, result[:valid]
  end
end
