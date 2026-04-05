require "test_helper"

class Physics::ResistorColorCodeCalculatorTest < ActiveSupport::TestCase
  test "4-band: brown-black-red-gold = 1k ohm, 5% tolerance" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "brown", band2: "black", multiplier: "red", tolerance: "gold"
    ).call
    assert result[:valid]
    assert_equal 1000.0, result[:resistance_ohms]
    assert_equal 5.0, result[:tolerance_percent]
    assert_in_delta 950.0, result[:min_resistance_ohms], 0.01
    assert_in_delta 1050.0, result[:max_resistance_ohms], 0.01
  end

  test "4-band: red-violet-orange-silver = 27k ohm, 10% tolerance" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "red", band2: "violet", multiplier: "orange", tolerance: "silver"
    ).call
    assert result[:valid]
    assert_equal 27_000.0, result[:resistance_ohms]
    assert_equal 10.0, result[:tolerance_percent]
    assert_in_delta 24_300.0, result[:min_resistance_ohms], 0.01
    assert_in_delta 29_700.0, result[:max_resistance_ohms], 0.01
  end

  test "5-band: brown-black-black-brown-brown = 1k ohm, 1% tolerance" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 5, band1: "brown", band2: "black", band3: "black", multiplier: "brown", tolerance: "brown"
    ).call
    assert result[:valid]
    # 100 * 10 = 1000
    assert_equal 1000.0, result[:resistance_ohms]
    assert_equal 1.0, result[:tolerance_percent]
    assert_equal 5, result[:bands]
  end

  test "5-band: yellow-violet-black-red-green = 47k ohm, 0.5% tolerance" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 5, band1: "yellow", band2: "violet", band3: "black", multiplier: "red", tolerance: "green"
    ).call
    assert result[:valid]
    # 470 * 100 = 47000
    assert_equal 47_000.0, result[:resistance_ohms]
    assert_equal 0.5, result[:tolerance_percent]
  end

  test "gold multiplier: 4-band red-violet-gold-gold = 2.7 ohm" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "red", band2: "violet", multiplier: "gold", tolerance: "gold"
    ).call
    assert result[:valid]
    assert_in_delta 2.7, result[:resistance_ohms], 0.001
  end

  test "silver multiplier: 4-band green-blue-silver-gold = 0.56 ohm" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "green", band2: "blue", multiplier: "silver", tolerance: "gold"
    ).call
    assert result[:valid]
    assert_in_delta 0.56, result[:resistance_ohms], 0.001
  end

  test "no tolerance (20%): 4-band brown-black-red-none" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "brown", band2: "black", multiplier: "red", tolerance: "none"
    ).call
    assert result[:valid]
    assert_equal 20.0, result[:tolerance_percent]
    assert_in_delta 800.0, result[:min_resistance_ohms], 0.01
    assert_in_delta 1200.0, result[:max_resistance_ohms], 0.01
  end

  test "resistance_display formats kilohms correctly" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "brown", band2: "black", multiplier: "orange", tolerance: "gold"
    ).call
    assert result[:valid]
    assert_equal 10_000.0, result[:resistance_ohms]
    assert_match(/k/, result[:resistance_display])
  end

  test "invalid band1 color returns error" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "pink", band2: "black", multiplier: "red", tolerance: "gold"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Band 1 color is invalid"
  end

  test "invalid number of bands returns error" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 3, band1: "brown", band2: "black", multiplier: "red", tolerance: "gold"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Number of bands must be 4 or 5"
  end

  test "5-band without band3 returns error" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 5, band1: "brown", band2: "black", multiplier: "red", tolerance: "gold"
    ).call
    refute result[:valid]
  end

  test "string coercion for bands parameter" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: "4", band1: "brown", band2: "black", multiplier: "red", tolerance: "gold"
    ).call
    assert result[:valid]
    assert_equal 1000.0, result[:resistance_ohms]
  end

  test "large value: blue multiplier = megaohm range" do
    result = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "brown", band2: "black", multiplier: "blue", tolerance: "gold"
    ).call
    assert result[:valid]
    # 10 * 1_000_000 = 10M ohm
    assert_equal 10_000_000.0, result[:resistance_ohms]
    assert_match(/M/, result[:resistance_display])
  end

  test "errors accessor starts empty" do
    calc = Physics::ResistorColorCodeCalculator.new(
      bands: 4, band1: "brown", band2: "black", multiplier: "red", tolerance: "gold"
    )
    assert_equal [], calc.errors
  end
end
