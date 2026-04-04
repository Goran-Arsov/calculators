require "test_helper"

class Health::DogFoodCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates daily calories for normal adult dog" do
    # 30 lbs = 13.608 kg, RER = 70 * 13.608^0.75 = ~496
    # Daily = 496 * 1.4 = ~694
    result = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    assert_in_delta 694, result[:daily_calories], 5
  end

  test "calculates RER correctly" do
    # 50 lbs = 22.68 kg, RER = 70 * 22.68^0.75
    weight_kg = 50 * 0.453592
    expected_rer = 70 * (weight_kg**0.75)
    result = Health::DogFoodCalculator.new(weight_lbs: 50, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    assert_in_delta expected_rer, result[:rer], 1
  end

  test "calculates cups per day with default kcal" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    expected_cups = result[:daily_calories].to_f / 350
    assert_in_delta expected_cups, result[:cups_per_day], 0.1
  end

  test "per meal is half of cups per day" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    assert_in_delta result[:cups_per_day] / 2.0, result[:per_meal_cups], 0.01
  end

  test "returns all expected fields" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30).call
    assert result[:valid]
    assert result[:weight_lbs]
    assert result[:weight_kg]
    assert result[:activity_level]
    assert result[:age_category]
    assert result[:rer]
    assert result[:multiplier]
    assert result[:daily_calories]
    assert result[:cups_per_day]
    assert result[:per_meal_cups]
    assert result[:kcal_per_cup]
  end

  # --- Activity level multipliers ---

  test "low activity needs fewer calories than normal" do
    low = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "low", age_category: "adult").call
    normal = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert low[:daily_calories] < normal[:daily_calories]
  end

  test "active needs more calories than normal" do
    active = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "active", age_category: "adult").call
    normal = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert active[:daily_calories] > normal[:daily_calories]
  end

  test "very active needs more calories than active" do
    very_active = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "very_active", age_category: "adult").call
    active = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "active", age_category: "adult").call
    assert very_active[:daily_calories] > active[:daily_calories]
  end

  # --- Age category multipliers ---

  test "puppy needs more calories than adult" do
    puppy = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "puppy").call
    adult = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert puppy[:daily_calories] > adult[:daily_calories]
  end

  test "senior needs fewer calories than adult" do
    senior = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "senior").call
    adult = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "normal", age_category: "adult").call
    assert senior[:daily_calories] < adult[:daily_calories]
  end

  # --- Custom kcal per cup ---

  test "custom kcal per cup changes cups per day" do
    low_cal = Health::DogFoodCalculator.new(weight_lbs: 30, kcal_per_cup: 250).call
    high_cal = Health::DogFoodCalculator.new(weight_lbs: 30, kcal_per_cup: 450).call
    assert low_cal[:cups_per_day] > high_cal[:cups_per_day]
    assert_equal low_cal[:daily_calories], high_cal[:daily_calories]
  end

  # --- Tiny and large dogs ---

  test "tiny dog (5 lbs) gets valid result" do
    result = Health::DogFoodCalculator.new(weight_lbs: 5, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    assert result[:daily_calories] > 0
    assert result[:cups_per_day] > 0
  end

  test "large dog (150 lbs) gets valid result" do
    result = Health::DogFoodCalculator.new(weight_lbs: 150, activity_level: "normal", age_category: "adult").call
    assert result[:valid]
    assert result[:daily_calories] > 0
    assert result[:cups_per_day] > 0
  end

  test "large dog needs more calories than tiny dog" do
    tiny = Health::DogFoodCalculator.new(weight_lbs: 5, activity_level: "normal", age_category: "adult").call
    large = Health::DogFoodCalculator.new(weight_lbs: 150, activity_level: "normal", age_category: "adult").call
    assert large[:daily_calories] > tiny[:daily_calories]
  end

  # --- Default values ---

  test "defaults to normal activity and adult age" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30).call
    assert result[:valid]
    assert_equal "normal", result[:activity_level]
    assert_equal "adult", result[:age_category]
  end

  test "defaults kcal per cup to 350" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30).call
    assert result[:valid]
    assert_equal 350, result[:kcal_per_cup]
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::DogFoodCalculator.new(weight_lbs: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative weight returns error" do
    result = Health::DogFoodCalculator.new(weight_lbs: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "unrealistic weight returns error" do
    result = Health::DogFoodCalculator.new(weight_lbs: 400).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be realistic (up to 350 lbs)"
  end

  test "invalid activity level returns error" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30, activity_level: "extreme").call
    refute result[:valid]
    assert_includes result[:errors], "Activity level must be low, normal, active, or very_active"
  end

  test "invalid age category returns error" do
    result = Health::DogFoodCalculator.new(weight_lbs: 30, age_category: "baby").call
    refute result[:valid]
    assert_includes result[:errors], "Age category must be puppy, adult, or senior"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::DogFoodCalculator.new(weight_lbs: 30)
    assert_equal [], calc.errors
  end
end
