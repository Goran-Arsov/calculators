require "test_helper"

class Alcohol::StrikeWaterCalculatorTest < ActiveSupport::TestCase
  test "typical 10 lb batch at 1.25 ratio targeting 152 from 70" do
    result = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 70,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 1.25
    ).call
    assert_equal true, result[:valid]
    # Tw = (0.2 / 1.25) * (152 - 70) + 152 = 13.12 + 152 = 165.12
    assert_in_delta 165.1, result[:strike_water_temp_f], 0.1
    assert_equal 12.5, result[:water_volume_qt]
    assert_equal 3.13, result[:water_volume_gal]
  end

  test "celsius conversion of strike temp" do
    result = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 70,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 1.25
    ).call
    assert_in_delta 74.0, result[:strike_water_temp_c], 0.1
  end

  test "thinner mash needs less hot water" do
    thick = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 70,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 1.0
    ).call
    thin = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 70,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 2.0
    ).call
    # Thinner mash → strike temp closer to target
    assert thin[:strike_water_temp_f] < thick[:strike_water_temp_f]
  end

  test "warmer grain needs less hot water" do
    cold = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 50,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 1.25
    ).call
    warm = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 80,
      target_mash_temp_f: 152, water_to_grain_ratio_qt_per_lb: 1.25
    ).call
    assert warm[:strike_water_temp_f] < cold[:strike_water_temp_f]
  end

  test "error when grain weight is zero" do
    result = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 0, grain_temp_f: 70, target_mash_temp_f: 152
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Grain weight must be greater than zero"
  end

  test "error when target lower than grain temp" do
    result = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 160, target_mash_temp_f: 152
    ).call
    assert_equal false, result[:valid]
    assert_match(/higher than grain/, result[:errors].join)
  end

  test "error when grain temp out of range" do
    result = Alcohol::StrikeWaterCalculator.new(
      grain_weight_lb: 10, grain_temp_f: 200, target_mash_temp_f: 152
    ).call
    assert_equal false, result[:valid]
    assert_match(/Grain temperature/, result[:errors].join)
  end
end
