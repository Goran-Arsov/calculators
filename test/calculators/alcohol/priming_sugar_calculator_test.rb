require "test_helper"

class Alcohol::PrimingSugarCalculatorTest < ActiveSupport::TestCase
  test "typical 5 gallon ale at 68F to 2.4 vols" do
    result = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "corn_sugar"
    ).call
    assert_equal true, result[:valid]
    # Standard answer is ~115-120g corn sugar
    assert result[:sugar_grams].between?(110, 125)
    assert_equal "corn_sugar", result[:sugar_type]
  end

  test "table sugar requires less weight than corn sugar" do
    corn = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "corn_sugar"
    ).call
    table = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "table_sugar"
    ).call
    assert table[:sugar_grams] < corn[:sugar_grams]
    # Table sugar is ~91% of corn sugar weight
    assert_in_delta corn[:sugar_grams] * 0.91, table[:sugar_grams], 1
  end

  test "dme requires more weight than corn sugar" do
    corn = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "corn_sugar"
    ).call
    dme = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "dme"
    ).call
    assert dme[:sugar_grams] > corn[:sugar_grams]
  end

  test "warmer fermentation needs more priming sugar" do
    cool = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 50, target_co2_volumes: 2.4
    ).call
    warm = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 75, target_co2_volumes: 2.4
    ).call
    # Warmer beer holds less residual CO2 → more priming sugar needed
    assert warm[:sugar_grams] > cool[:sugar_grams]
  end

  test "ounces conversion is correct" do
    result = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68, target_co2_volumes: 2.4
    ).call
    assert_in_delta result[:sugar_grams] / 28.3495, result[:sugar_oz], 0.05
  end

  test "carbonation style category" do
    result = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68, target_co2_volumes: 2.4
    ).call
    assert_match(/American/, result[:carbonation_style])
  end

  test "error when sugar type is invalid" do
    result = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68,
      target_co2_volumes: 2.4, sugar_type: "honey"
    ).call
    assert_equal false, result[:valid]
  end

  test "error when target co2 out of range" do
    result = Alcohol::PrimingSugarCalculator.new(
      batch_volume_gal: 5, fermentation_temp_f: 68, target_co2_volumes: 10
    ).call
    assert_equal false, result[:valid]
  end
end
