require "test_helper"

class Alcohol::KegForceCarbonationCalculatorTest < ActiveSupport::TestCase
  test "38F at 2.5 vols matches published carbonation tables" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 2.5
    ).call
    assert_equal true, result[:valid]
    # Standard reference: ~11 PSI at 38F for 2.5 vols
    assert_in_delta 11.2, result[:regulator_psi], 0.5
  end

  test "warmer beer needs higher pressure" do
    cold = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 36, target_co2_volumes: 2.5
    ).call
    warm = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 50, target_co2_volumes: 2.5
    ).call
    assert warm[:regulator_psi] > cold[:regulator_psi]
  end

  test "higher target vols needs higher pressure" do
    low = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 2.0
    ).call
    high = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 3.0
    ).call
    assert high[:regulator_psi] > low[:regulator_psi]
  end

  test "kpa conversion is correct" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 2.5
    ).call
    # kPa is calculated from the unrounded PSI, so allow a small tolerance vs the displayed PSI
    assert_in_delta result[:regulator_psi] * 6.89476, result[:regulator_kpa], 0.5
  end

  test "celsius conversion of temperature" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 2.5
    ).call
    assert_in_delta 3.3, result[:beer_temp_c], 0.1
  end

  test "carbonation style category for IPA" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 2.6
    ).call
    assert_match(/American|pilsner|IPA/i, result[:carbonation_style])
  end

  test "error when temp out of range" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 100, target_co2_volumes: 2.5
    ).call
    assert_equal false, result[:valid]
  end

  test "error when target co2 out of range" do
    result = Alcohol::KegForceCarbonationCalculator.new(
      beer_temp_f: 38, target_co2_volumes: 0.1
    ).call
    assert_equal false, result[:valid]
  end
end
