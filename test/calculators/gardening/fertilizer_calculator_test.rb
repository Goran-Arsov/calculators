require "test_helper"

class Gardening::FertilizerCalculatorTest < ActiveSupport::TestCase
  test "5000 sqft at 1 lb N/1000 with 21-0-0 urea" do
    result = Gardening::FertilizerCalculator.new(
      area_sqft: 5000, nitrogen_rate_per_1000: 1, fertilizer_n_percent: 21
    ).call
    assert_equal true, result[:valid]
    assert_in_delta 5.0, result[:pounds_of_nitrogen], 0.001
    assert_in_delta 23.81, result[:pounds_fertilizer], 0.01
  end

  test "10-10-10 at 1 lb N per 1000 sqft" do
    result = Gardening::FertilizerCalculator.new(
      area_sqft: 1000, nitrogen_rate_per_1000: 1, fertilizer_n_percent: 10
    ).call
    assert_in_delta 10.0, result[:pounds_fertilizer], 0.001
  end

  test "invalid percent errors" do
    result = Gardening::FertilizerCalculator.new(
      area_sqft: 5000, nitrogen_rate_per_1000: 1, fertilizer_n_percent: 0
    ).call
    assert_equal false, result[:valid]
  end

  test "negative area errors" do
    result = Gardening::FertilizerCalculator.new(
      area_sqft: -100, nitrogen_rate_per_1000: 1, fertilizer_n_percent: 20
    ).call
    assert_equal false, result[:valid]
  end
end
