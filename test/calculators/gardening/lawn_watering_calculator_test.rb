require "test_helper"

class Gardening::LawnWateringCalculatorTest < ActiveSupport::TestCase
  test "1 inch over 1000 sq ft is 623 gallons" do
    result = Gardening::LawnWateringCalculator.new(
      area_sqft: 1000, inches_per_week: 1
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 623.4, result[:gallons_per_week], 0.1
  end

  test "daily gallons divides by 7" do
    result = Gardening::LawnWateringCalculator.new(
      area_sqft: 7000, inches_per_week: 1
    ).call
    assert_in_delta result[:gallons_per_week] / 7.0, result[:gallons_per_day], 0.1
  end

  test "sprinkler minutes with gpm" do
    result = Gardening::LawnWateringCalculator.new(
      area_sqft: 1000, inches_per_week: 1, sprinkler_gpm: 5
    ).call
    # 623.4 gal / 5 gpm ≈ 125 min
    assert_in_delta 125, result[:sprinkler_minutes_per_week], 1
  end

  test "without gpm sprinkler_minutes is nil" do
    result = Gardening::LawnWateringCalculator.new(
      area_sqft: 1000, inches_per_week: 1
    ).call
    assert_nil result[:sprinkler_minutes_per_week]
  end

  test "zero area errors" do
    result = Gardening::LawnWateringCalculator.new(area_sqft: 0, inches_per_week: 1).call
    assert_equal false, result[:valid]
  end
end
