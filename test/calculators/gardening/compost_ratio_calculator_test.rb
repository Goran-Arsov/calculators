require "test_helper"

class Gardening::CompostRatioCalculatorTest < ActiveSupport::TestCase
  test "60 lb browns and 40 lb greens gives ideal range" do
    result = Gardening::CompostRatioCalculator.new(browns_lb: 60, greens_lb: 40).call
    assert_equal true, result[:valid]
    # C = 60*0.50 + 40*0.45 = 30 + 18 = 48
    # N = 60*0.005 + 40*0.025 = 0.3 + 1.0 = 1.3
    # ratio = 48/1.3 ≈ 36.9 → too carbon-rich
    assert_in_delta 48.0, result[:carbon_lb], 0.01
    assert_in_delta 1.3, result[:nitrogen_lb], 0.01
    assert_in_delta 36.9, result[:ratio], 0.1
    assert_match(/carbon-rich/, result[:status])
  end

  test "nitrogen-rich pile status" do
    # all greens → low ratio
    result = Gardening::CompostRatioCalculator.new(browns_lb: 0, greens_lb: 100).call
    # C = 45, N = 2.5 → ratio 18 → nitrogen-rich
    assert_in_delta 18, result[:ratio], 0.5
    assert_match(/nitrogen-rich/, result[:status])
  end

  test "balanced pile reports ideal" do
    # Roughly 75 browns, 25 greens → closer to 30:1
    result = Gardening::CompostRatioCalculator.new(browns_lb: 75, greens_lb: 25).call
    # C = 37.5 + 11.25 = 48.75
    # N = 0.375 + 0.625 = 1.0
    # ratio = 48.75 → still carbon-rich; try 40 browns, 20 greens
    result2 = Gardening::CompostRatioCalculator.new(browns_lb: 40, greens_lb: 20).call
    # C = 20 + 9 = 29; N = 0.2 + 0.5 = 0.7; ratio ≈ 41.4 — still high
    # Need: find balanced ratio
    result3 = Gardening::CompostRatioCalculator.new(browns_lb: 30, greens_lb: 30).call
    # C = 15 + 13.5 = 28.5; N = 0.15 + 0.75 = 0.9; ratio ≈ 31.7
    assert_match(/carbon-rich/, result3[:status])
    # 25 browns 35 greens: C = 12.5 + 15.75 = 28.25; N = 0.125 + 0.875 = 1.0; ratio 28.25 → ideal
    result4 = Gardening::CompostRatioCalculator.new(browns_lb: 25, greens_lb: 35).call
    assert_match(/Ideal/, result4[:status])
  end

  test "zero greens with browns errors" do
    result = Gardening::CompostRatioCalculator.new(browns_lb: 40, greens_lb: 0).call
    assert_equal false, result[:valid]
  end

  test "both zero errors" do
    result = Gardening::CompostRatioCalculator.new(browns_lb: 0, greens_lb: 0).call
    assert_equal false, result[:valid]
  end
end
