require "test_helper"

class Cooking::SmokeTimeCalculatorTest < ActiveSupport::TestCase
  test "happy path: brisket at 225" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "beef_brisket", weight_lbs: 12, smoker_temp: 225)
    result = calc.call

    assert result[:valid]
    assert_equal 200, result[:target_internal_temp_f]
    assert_equal "standard", result[:temp_range]
    assert result[:total_minutes] > 0
    assert result[:stall_minutes] > 0  # brisket has stall
    assert result[:rest_time_minutes] >= 30
  end

  test "happy path: chicken at 275" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "whole_chicken", weight_lbs: 4, smoker_temp: 275)
    result = calc.call

    assert result[:valid]
    assert_equal 165, result[:target_internal_temp_f]
    assert_equal "hot", result[:temp_range]
    assert_equal 0, result[:stall_minutes]  # no stall for chicken
  end

  test "happy path: pork butt low and slow" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "pork_butt", weight_lbs: 8, smoker_temp: 210)
    result = calc.call

    assert result[:valid]
    assert_equal "low", result[:temp_range]
    assert result[:stall_minutes] > 0
    assert result[:rest_time_minutes] >= 30
  end

  test "zero weight returns error" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "beef_brisket", weight_lbs: 0, smoker_temp: 225)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Weight must be positive"
  end

  test "temperature too low returns error" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "beef_brisket", weight_lbs: 10, smoker_temp: 100)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Smoker temperature must be between 180 and 400 F"
  end

  test "temperature too high returns error" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "beef_brisket", weight_lbs: 10, smoker_temp: 500)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Smoker temperature must be between 180 and 400 F"
  end

  test "unknown meat type returns error" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "unknown", weight_lbs: 5, smoker_temp: 225)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown meat type: unknown"
  end

  test "small cut has no stall time" do
    calc = Cooking::SmokeTimeCalculator.new(meat_type: "beef_brisket", weight_lbs: 2, smoker_temp: 225)
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:stall_minutes]
  end

  test "available_meats returns list" do
    meats = Cooking::SmokeTimeCalculator.available_meats
    assert_includes meats, "beef_brisket"
    assert_includes meats, "pork_butt"
    assert_includes meats, "salmon"
  end
end
