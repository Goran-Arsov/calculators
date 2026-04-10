require "test_helper"

class Alcohol::YeastPitchCalculatorTest < ActiveSupport::TestCase
  test "typical 5 gallon ale at 1.050" do
    result = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050,
      beer_type: "ale", yeast_type: "dry", yeast_age_days: 0
    ).call
    assert_equal true, result[:valid]
    # Plato = 12.5
    assert_in_delta 12.5, result[:plato], 0.1
    # Cells = 0.75 * 18927 * 12.5 / 1000 ≈ 177.4 billion
    assert_in_delta 177, result[:cells_needed_billion], 5
    assert_equal "dry", result[:yeast_type]
    assert_equal 0.75, result[:pitch_rate_million_per_ml_per_p]
  end

  test "lager doubles the pitch rate" do
    ale = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, beer_type: "ale"
    ).call
    lager = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, beer_type: "lager"
    ).call
    assert_in_delta lager[:cells_needed_billion], ale[:cells_needed_billion] * 2, 1
  end

  test "high gravity bumps the pitch rate" do
    normal = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, beer_type: "ale"
    ).call
    high = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.080, beer_type: "ale"
    ).call
    # Higher gravity uses 1.0 instead of 0.75 pitch rate
    assert_equal 1.0, high[:pitch_rate_million_per_ml_per_p]
  end

  test "viability decreases with age" do
    fresh = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, yeast_type: "dry", yeast_age_days: 0
    ).call
    old = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, yeast_type: "dry", yeast_age_days: 60
    ).call
    assert old[:viability_pct] < fresh[:viability_pct]
  end

  test "dry yeast packs round up" do
    result = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, yeast_type: "dry", yeast_age_days: 0
    ).call
    # 177B cells needed; one fresh 11g pack has ~220B cells, so 1 pack
    assert_equal 1, result[:dry_yeast_packs_11g]
    assert_equal 11, result[:dry_yeast_grams]
  end

  test "liquid yeast returns starter and pack info" do
    result = Alcohol::YeastPitchCalculator.new(
      batch_volume_gal: 5, original_gravity: 1.050, yeast_type: "liquid", yeast_age_days: 0
    ).call
    assert_equal "liquid", result[:yeast_type]
    assert result[:liquid_packs_no_starter].is_a?(Integer)
    assert result[:starter_size_l_one_pack].is_a?(Numeric)
  end

  test "error when batch volume is zero" do
    result = Alcohol::YeastPitchCalculator.new(batch_volume_gal: 0, original_gravity: 1.050).call
    assert_equal false, result[:valid]
  end

  test "error when og too high" do
    result = Alcohol::YeastPitchCalculator.new(batch_volume_gal: 5, original_gravity: 1.200).call
    assert_equal false, result[:valid]
  end
end
