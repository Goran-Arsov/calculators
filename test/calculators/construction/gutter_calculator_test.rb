require "test_helper"

class Construction::GutterCalculatorTest < ActiveSupport::TestCase
  test "four eave rectangular house with 5-inch" do
    result = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 40, 40, 30, 30 ], gutter_size: "5_inch", downspout_length_ft: 10
    ).call
    assert_equal true, result[:valid]
    # total gutter = 140 ft
    # downspouts per eave: 40/35 → 2, 40/35 → 2, 30/35 → 1, 30/35 → 1 = 6
    assert_in_delta 140.0, result[:total_gutter_feet], 0.01
    assert_equal 6, result[:downspout_count]
    assert_in_delta 60.0, result[:downspout_feet], 0.01
  end

  test "6-inch allows longer runs per downspout" do
    five = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 40 ], gutter_size: "5_inch"
    ).call
    six = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 40 ], gutter_size: "6_inch"
    ).call
    assert six[:downspout_count] < five[:downspout_count]
  end

  test "minimum 1 downspout per eave" do
    result = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 15 ], gutter_size: "5_inch"
    ).call
    assert_equal 1, result[:downspout_count]
  end

  test "empty eaves errors" do
    result = Construction::GutterCalculator.new(
      eave_lengths_ft: [], gutter_size: "5_inch"
    ).call
    assert_equal false, result[:valid]
  end

  test "invalid size errors" do
    result = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 40 ], gutter_size: "99_inch"
    ).call
    assert_equal false, result[:valid]
  end

  test "cost calculation" do
    result = Construction::GutterCalculator.new(
      eave_lengths_ft: [ 40 ], gutter_size: "5_inch",
      downspout_length_ft: 10, price_per_foot: 5
    ).call
    # 40 + 20 (2 downspouts × 10) = 60 ft × $5 = $300
    assert_in_delta 300.0, result[:total_cost], 0.01
  end
end
