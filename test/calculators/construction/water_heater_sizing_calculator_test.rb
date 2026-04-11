require "test_helper"

class Construction::WaterHeaterSizingCalculatorTest < ActiveSupport::TestCase
  test "family of 4, 2 bathrooms" do
    result = Construction::WaterHeaterSizingCalculator.new(
      people: 4, bathrooms: 2, showers: 4, baths: 0,
      dishwasher: true, clothes_washer: true
    ).call
    assert_equal true, result[:valid]
    # showers: 4*10=40; baths: 0; hand: 4*2=8; kitchen: 4
    # dishwasher: 6; clothes: 7 → total 65
    assert_in_delta 65, result[:peak_hour_gallons], 0.1
    assert_equal 50, result[:recommended_tank_gallons]
  end

  test "tank size jumps with more people" do
    big = Construction::WaterHeaterSizingCalculator.new(
      people: 6, bathrooms: 3
    ).call
    small = Construction::WaterHeaterSizingCalculator.new(
      people: 2, bathrooms: 1
    ).call
    assert big[:recommended_tank_gallons] > small[:recommended_tank_gallons]
  end

  test "tankless GPM baseline is 5" do
    result = Construction::WaterHeaterSizingCalculator.new(
      people: 2, bathrooms: 1
    ).call
    assert_in_delta 5.0, result[:tankless_gpm_required], 0.01
  end

  test "dishwasher bumps tankless GPM" do
    result = Construction::WaterHeaterSizingCalculator.new(
      people: 4, bathrooms: 2, dishwasher: true
    ).call
    assert result[:tankless_gpm_required] > 5.0
  end

  test "zero people errors" do
    result = Construction::WaterHeaterSizingCalculator.new(people: 0, bathrooms: 1).call
    assert_equal false, result[:valid]
  end
end
