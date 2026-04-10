require "test_helper"

class Alcohol::SrmCalculatorTest < ActiveSupport::TestCase
  test "typical pale ale recipe" do
    result = Alcohol::SrmCalculator.new(
      malts: [
        { weight_lb: 9.0, lovibond: 2.0 },
        { weight_lb: 1.0, lovibond: 60.0 }
      ],
      batch_volume_gal: 5.0
    ).call
    assert_equal true, result[:valid]
    # MCU = (9*2 + 1*60) / 5 = 78/5 = 15.6
    assert_equal 15.6, result[:mcu]
    # SRM = 1.4922 * 15.6^0.6859 ≈ 9.8
    assert_in_delta 9.8, result[:srm], 0.2
  end

  test "ebc is roughly 1.97x srm" do
    result = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 10, lovibond: 4 } ],
      batch_volume_gal: 5
    ).call
    assert_in_delta result[:srm] * 1.97, result[:ebc], 0.1
  end

  test "single base malt produces pale color" do
    result = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 10, lovibond: 2 } ],
      batch_volume_gal: 5
    ).call
    assert result[:srm] < 6
    assert_match(/straw|pale/i, result[:beer_style])
  end

  test "stout recipe produces dark color" do
    result = Alcohol::SrmCalculator.new(
      malts: [
        { weight_lb: 8, lovibond: 2 },
        { weight_lb: 1, lovibond: 60 },
        { weight_lb: 1, lovibond: 500 }
      ],
      batch_volume_gal: 5
    ).call
    assert result[:srm] > 30
    assert_match(/black|dark/i, result[:beer_style])
  end

  test "morey diminishing returns" do
    # Doubling dark malt does not double SRM
    base = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 1, lovibond: 100 } ], batch_volume_gal: 5
    ).call
    double = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 2, lovibond: 100 } ], batch_volume_gal: 5
    ).call
    assert double[:srm] < (base[:srm] * 2)
  end

  test "hex_color is returned" do
    result = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 10, lovibond: 4 } ], batch_volume_gal: 5
    ).call
    assert_match(/^#[0-9A-F]{6}$/, result[:hex_color])
  end

  test "error when batch volume is zero" do
    result = Alcohol::SrmCalculator.new(
      malts: [ { weight_lb: 10, lovibond: 2 } ], batch_volume_gal: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Batch volume must be greater than zero"
  end

  test "error when malts list is empty" do
    result = Alcohol::SrmCalculator.new(malts: [], batch_volume_gal: 5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one malt is required"
  end
end
