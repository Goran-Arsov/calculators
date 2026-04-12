require "test_helper"

class Cooking::MeatCookingTimeCalculatorTest < ActiveSupport::TestCase
  test "happy path: beef roast medium rare oven" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "beef", cut: "roast", weight_lbs: 5, doneness: "medium_rare", method: "oven"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 90, result[:total_minutes]
    assert_equal 135, result[:internal_temp_f]
    assert_equal 18, result[:minutes_per_lb]
    assert_equal 1, result[:hours]
    assert_equal 30, result[:minutes]
  end

  test "happy path: chicken whole well done oven" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "chicken", cut: "whole", weight_lbs: 4, doneness: "well_done", method: "oven"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 80, result[:total_minutes]
    assert_equal 165, result[:internal_temp_f]
    assert_equal 10, result[:rest_time_minutes]
  end

  test "happy path: turkey whole oven" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "turkey", cut: "whole", weight_lbs: 15, doneness: "well_done", method: "oven"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 225, result[:total_minutes]
    assert_equal 165, result[:internal_temp_f]
    assert_equal 30, result[:rest_time_minutes]  # >= 10 lbs
  end

  test "happy path: lamb rack rare grill" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "lamb", cut: "rack", weight_lbs: 2, doneness: "rare", method: "grill"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 20, result[:total_minutes]
    assert_equal 125, result[:internal_temp_f]
  end

  test "happy path: pork pulled pork smoker" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "pork", cut: "pulled_pork", weight_lbs: 8, doneness: "well_done", method: "smoker"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 600, result[:total_minutes]
    assert_equal 200, result[:internal_temp_f]
    assert_equal 30, result[:rest_time_minutes]
  end

  test "zero weight returns error" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "beef", cut: "roast", weight_lbs: 0, doneness: "medium", method: "oven"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Weight must be positive"
  end

  test "unknown meat type returns error" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "fish", cut: "fillet", weight_lbs: 1, doneness: "medium", method: "oven"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown meat type: fish"
  end

  test "unknown cut returns error" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "beef", cut: "unknown", weight_lbs: 5, doneness: "medium", method: "oven"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown cut for beef: unknown"
  end

  test "string inputs are coerced" do
    calc = Cooking::MeatCookingTimeCalculator.new(
      meat_type: "beef", cut: "roast", weight_lbs: "5", doneness: "medium", method: "oven"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 100, result[:total_minutes]
  end

  test "available_options returns data structure" do
    options = Cooking::MeatCookingTimeCalculator.available_options
    assert options.key?("beef")
    assert options.key?("pork")
    assert options.key?("chicken")
    assert options.key?("turkey")
    assert options.key?("lamb")
  end
end
