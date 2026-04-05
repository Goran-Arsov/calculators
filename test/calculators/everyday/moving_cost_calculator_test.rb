require "test_helper"

class Everyday::MovingCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "local move studio, no extras" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 20, home_size: "studio").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 400, result[:estimate_low]
    assert_equal 800, result[:estimate_high]
    assert_equal false, result[:is_long_distance]
  end

  test "local move 3bed, no extras" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 50, home_size: "3bed").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1200, result[:estimate_low]
    assert_equal 2200, result[:estimate_high]
  end

  test "long distance move 2bed" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 500, home_size: "2bed").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:estimate_low] > 800  # base is 800 + distance factor
    assert result[:estimate_high] > 1500
    assert_equal true, result[:is_long_distance]
  end

  test "extras add to cost range" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 20, home_size: "studio", extras: "packing,piano").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # Base: 400-800, packing: 200-600, piano: 200-500
    assert_equal 800, result[:estimate_low]
    assert_equal 1900, result[:estimate_high]
    assert_equal 400, result[:extras_low]
    assert_equal 1100, result[:extras_high]
  end

  test "extras breakdown is returned" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 30, home_size: "1bed", extras: "insurance").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:extras_breakdown].size
    assert_equal "insurance", result[:extras_breakdown][0][:name]
  end

  test "boundary 100 miles is local" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 100, home_size: "studio").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal false, result[:is_long_distance]
  end

  test "boundary 101 miles is long distance" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 101, home_size: "studio").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal true, result[:is_long_distance]
  end

  test "5bed large home" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 30, home_size: "5bed").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2000, result[:estimate_low]
    assert_equal 4000, result[:estimate_high]
  end

  # --- Validation errors ---

  test "error when distance is zero" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 0, home_size: "studio").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Distance must be greater than zero"
  end

  test "error for unknown home size" do
    result = Everyday::MovingCostCalculator.new(distance_miles: 50, home_size: "mansion").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown home size") }
  end

  test "string coercion for distance" do
    result = Everyday::MovingCostCalculator.new(distance_miles: "50", home_size: "studio").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 400, result[:estimate_low]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::MovingCostCalculator.new(distance_miles: 50, home_size: "studio")
    assert_equal [], calc.errors
  end
end
