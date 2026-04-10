require "test_helper"

class Alcohol::IbuCalculatorTest < ActiveSupport::TestCase
  test "single 60 minute hop addition matches Tinseth tables" do
    result = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 1.0, alpha_acid_pct: 7.0, boil_time_min: 60 } ],
      batch_volume_gal: 5.0,
      original_gravity: 1.055
    ).call
    assert_equal true, result[:valid]
    # Tinseth at 1.055 OG, 60min, 7%AA, 1oz, 5gal ≈ 23 IBU
    assert_in_delta 23.0, result[:total_ibu], 1.0
  end

  test "multiple hop additions sum correctly" do
    result = Alcohol::IbuCalculator.new(
      hops: [
        { weight_oz: 1.0, alpha_acid_pct: 7.0, boil_time_min: 60 },
        { weight_oz: 0.5, alpha_acid_pct: 7.0, boil_time_min: 15 }
      ],
      batch_volume_gal: 5.0,
      original_gravity: 1.055
    ).call
    assert_equal 2, result[:hop_breakdown].size
    sum = result[:hop_breakdown].sum { |h| h[:ibus] }
    assert_in_delta sum, result[:total_ibu], 0.1
  end

  test "higher gravity reduces utilization" do
    low = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 1.0, alpha_acid_pct: 10.0, boil_time_min: 60 } ],
      batch_volume_gal: 5.0, original_gravity: 1.040
    ).call
    high = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 1.0, alpha_acid_pct: 10.0, boil_time_min: 60 } ],
      batch_volume_gal: 5.0, original_gravity: 1.090
    ).call
    assert high[:total_ibu] < low[:total_ibu]
  end

  test "zero boil time gives zero ibu" do
    result = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 1.0, alpha_acid_pct: 10.0, boil_time_min: 0 } ],
      batch_volume_gal: 5.0, original_gravity: 1.050
    ).call
    assert_equal 0.0, result[:total_ibu]
  end

  test "bitterness category for IPA range" do
    result = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 2.5, alpha_acid_pct: 10.0, boil_time_min: 60 } ],
      batch_volume_gal: 5.0, original_gravity: 1.060
    ).call
    assert_match(/IPA|Strong|Assertive/, result[:bitterness_category])
  end

  test "error when batch volume is zero" do
    result = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: 1.0, alpha_acid_pct: 7.0, boil_time_min: 60 } ],
      batch_volume_gal: 0, original_gravity: 1.050
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Batch volume must be greater than zero"
  end

  test "error when hops list is empty" do
    result = Alcohol::IbuCalculator.new(
      hops: [], batch_volume_gal: 5, original_gravity: 1.050
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one hop addition is required"
  end

  test "error when hop weight is negative" do
    result = Alcohol::IbuCalculator.new(
      hops: [ { weight_oz: -1, alpha_acid_pct: 7, boil_time_min: 60 } ],
      batch_volume_gal: 5, original_gravity: 1.050
    ).call
    assert_equal false, result[:valid]
    assert_match(/weight must be positive/, result[:errors].join)
  end
end
