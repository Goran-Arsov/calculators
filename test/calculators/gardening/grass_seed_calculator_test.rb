require "test_helper"

class Gardening::GrassSeedCalculatorTest < ActiveSupport::TestCase
  test "tall fescue new lawn at 5000 sq ft = 40 lb" do
    result = Gardening::GrassSeedCalculator.new(
      area_sqft: 5000, seed_type: "tall_fescue", purpose: "new"
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 40.0, result[:pounds], 0.001
    assert_in_delta 8.0, result[:rate_per_1000], 0.001
  end

  test "overseeding halves the rate" do
    new_lawn = Gardening::GrassSeedCalculator.new(
      area_sqft: 5000, seed_type: "tall_fescue", purpose: "new"
    ).call
    overseed = Gardening::GrassSeedCalculator.new(
      area_sqft: 5000, seed_type: "tall_fescue", purpose: "overseed"
    ).call
    assert_in_delta new_lawn[:pounds] / 2, overseed[:pounds], 0.001
  end

  test "kentucky bluegrass new lawn 2 lb / 1000" do
    result = Gardening::GrassSeedCalculator.new(
      area_sqft: 1000, seed_type: "kentucky_bluegrass"
    ).call
    assert_in_delta 2.0, result[:pounds], 0.001
  end

  test "unknown seed type errors" do
    result = Gardening::GrassSeedCalculator.new(
      area_sqft: 1000, seed_type: "bogus_grass"
    ).call
    assert_equal false, result[:valid]
  end
end
