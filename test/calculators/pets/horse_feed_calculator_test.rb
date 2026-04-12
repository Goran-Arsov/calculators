require "test_helper"

class Pets::HorseFeedCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates feed for 1000 lb horse at maintenance" do
    # Forage: 1000 * 0.015 = 15 lbs, Grain: 0 lbs
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "maintenance").call
    assert result[:valid]
    assert_in_delta 15.0, result[:forage_lbs_per_day], 0.5
    assert_in_delta 0.0, result[:grain_lbs_per_day], 0.1
  end

  test "returns all expected fields" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000).call
    assert result[:valid]
    assert result[:weight_lbs]
    assert result[:weight_kg]
    assert result[:activity_level]
    assert result[:forage_lbs_per_day]
    assert result[:forage_kg_per_day]
    assert result[:grain_lbs_per_day] >= 0
    assert result[:grain_kg_per_day] >= 0
    assert result[:total_feed_lbs_per_day]
    assert result[:daily_energy_mcal]
    assert result[:salt_oz_per_day]
    assert result[:mineral_oz_per_day]
    assert result[:water_gallons_min]
    assert result[:water_gallons_max]
    assert result[:forage_to_total_ratio]
  end

  # --- Activity levels ---

  test "moderate work needs more forage than maintenance" do
    maintenance = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "maintenance").call
    moderate = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "moderate").call
    assert moderate[:forage_lbs_per_day] > maintenance[:forage_lbs_per_day]
  end

  test "heavy work needs grain" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "heavy").call
    assert result[:valid]
    assert result[:grain_lbs_per_day] > 0
  end

  test "maintenance does not need grain" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "maintenance").call
    assert result[:valid]
    assert_in_delta 0.0, result[:grain_lbs_per_day], 0.01
  end

  test "intense work needs more energy than light" do
    light = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "light").call
    intense = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "intense").call
    assert intense[:daily_energy_mcal] > light[:daily_energy_mcal]
  end

  test "intense work needs more grain than moderate" do
    moderate = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "moderate").call
    intense = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "intense").call
    assert intense[:grain_lbs_per_day] > moderate[:grain_lbs_per_day]
  end

  # --- Weight scaling ---

  test "heavier horse needs more feed" do
    light = Pets::HorseFeedCalculator.new(weight_lbs: 800, activity_level: "moderate").call
    heavy = Pets::HorseFeedCalculator.new(weight_lbs: 1200, activity_level: "moderate").call
    assert heavy[:forage_lbs_per_day] > light[:forage_lbs_per_day]
    assert heavy[:total_feed_lbs_per_day] > light[:total_feed_lbs_per_day]
  end

  test "heavier horse needs more water" do
    light = Pets::HorseFeedCalculator.new(weight_lbs: 800).call
    heavy = Pets::HorseFeedCalculator.new(weight_lbs: 1200).call
    assert heavy[:water_gallons_max] > light[:water_gallons_max]
  end

  # --- Salt and minerals scale with weight ---

  test "salt scales with body weight" do
    result_1000 = Pets::HorseFeedCalculator.new(weight_lbs: 1000).call
    result_500 = Pets::HorseFeedCalculator.new(weight_lbs: 500).call
    assert_in_delta result_1000[:salt_oz_per_day], result_500[:salt_oz_per_day] * 2, 0.2
  end

  # --- Forage ratio ---

  test "maintenance is 100 percent forage" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "maintenance").call
    assert result[:valid]
    assert_equal 100, result[:forage_to_total_ratio]
  end

  test "heavy work has lower forage ratio than light" do
    light = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "light").call
    heavy = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "heavy").call
    assert heavy[:forage_to_total_ratio] < light[:forage_to_total_ratio]
  end

  # --- Default values ---

  test "defaults to maintenance activity" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000).call
    assert result[:valid]
    assert_equal "maintenance", result[:activity_level]
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "unrealistically light horse returns error" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 100).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("realistic") }
  end

  test "unrealistically heavy horse returns error" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 3000).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("realistic") }
  end

  test "invalid activity level returns error" do
    result = Pets::HorseFeedCalculator.new(weight_lbs: 1000, activity_level: "racing").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Activity level") }
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::HorseFeedCalculator.new(weight_lbs: 1000)
    assert_equal [], calc.errors
  end
end
