require "test_helper"

class Pets::CatFoodCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates daily calories for normal adult indoor cat" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10, age_category: "adult", activity_level: "moderate", environment: "indoor").call
    assert result[:valid]
    assert result[:daily_calories] > 0
    assert result[:cans_per_day] > 0
  end

  test "calculates RER correctly" do
    weight_kg = 10 * 0.453592
    expected_rer = 70 * (weight_kg**0.75)
    result = Pets::CatFoodCalculator.new(weight_lbs: 10).call
    assert result[:valid]
    assert_in_delta expected_rer, result[:rer], 1
  end

  test "returns all expected fields" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10).call
    assert result[:valid]
    assert result[:weight_lbs]
    assert result[:weight_kg]
    assert result[:age_category]
    assert result[:activity_level]
    assert result[:environment]
    assert result[:rer]
    assert result[:daily_calories]
    assert result[:cans_per_day]
    assert result[:oz_per_day]
    assert result[:kcal_per_can]
  end

  # --- Activity level effects ---

  test "inactive cats need fewer calories than moderate" do
    inactive = Pets::CatFoodCalculator.new(weight_lbs: 10, activity_level: "inactive").call
    moderate = Pets::CatFoodCalculator.new(weight_lbs: 10, activity_level: "moderate").call
    assert inactive[:daily_calories] < moderate[:daily_calories]
  end

  test "active cats need more calories than moderate" do
    active = Pets::CatFoodCalculator.new(weight_lbs: 10, activity_level: "active").call
    moderate = Pets::CatFoodCalculator.new(weight_lbs: 10, activity_level: "moderate").call
    assert active[:daily_calories] > moderate[:daily_calories]
  end

  # --- Age category effects ---

  test "kittens need more calories than adults" do
    kitten = Pets::CatFoodCalculator.new(weight_lbs: 5, age_category: "kitten").call
    adult = Pets::CatFoodCalculator.new(weight_lbs: 5, age_category: "adult").call
    assert kitten[:daily_calories] > adult[:daily_calories]
  end

  test "senior cats need fewer calories than adults" do
    senior = Pets::CatFoodCalculator.new(weight_lbs: 10, age_category: "senior").call
    adult = Pets::CatFoodCalculator.new(weight_lbs: 10, age_category: "adult").call
    assert senior[:daily_calories] < adult[:daily_calories]
  end

  # --- Environment effects ---

  test "outdoor cats need more calories than indoor" do
    outdoor = Pets::CatFoodCalculator.new(weight_lbs: 10, environment: "outdoor").call
    indoor = Pets::CatFoodCalculator.new(weight_lbs: 10, environment: "indoor").call
    assert outdoor[:daily_calories] > indoor[:daily_calories]
  end

  # --- Default values ---

  test "defaults to adult moderate indoor" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10).call
    assert result[:valid]
    assert_equal "adult", result[:age_category]
    assert_equal "moderate", result[:activity_level]
    assert_equal "indoor", result[:environment]
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "excessive weight returns error" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 35).call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("realistic") }
  end

  test "invalid activity level returns error" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10, activity_level: "extreme").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Activity level") }
  end

  test "invalid age category returns error" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10, age_category: "baby").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Age category") }
  end

  test "invalid environment returns error" do
    result = Pets::CatFoodCalculator.new(weight_lbs: 10, environment: "space").call
    refute result[:valid]
    assert result[:errors].any? { |e| e.include?("Environment") }
  end

  test "errors accessor returns empty array before call" do
    calc = Pets::CatFoodCalculator.new(weight_lbs: 10)
    assert_equal [], calc.errors
  end
end
