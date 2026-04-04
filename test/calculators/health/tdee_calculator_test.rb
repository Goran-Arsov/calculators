require "test_helper"

class Health::TdeeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: male ---

  test "calculates BMR and TDEE for male sedentary" do
    # BMR = 10×80 + 6.25×180 - 5×30 + 5 = 800 + 1125 - 150 + 5 = 1780
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "sedentary"
    ).call
    assert result[:valid]
    assert_equal 1780, result[:bmr]
    assert_equal (1780 * 1.2).round(0), result[:tdee]
    assert_equal "Sedentary (little or no exercise)", result[:activity_label]
  end

  test "calculates BMR and TDEE for male moderate" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "moderate"
    ).call
    assert result[:valid]
    assert_equal 1780, result[:bmr]
    assert_equal (1780 * 1.55).round(0), result[:tdee]
  end

  # --- Happy path: female ---

  test "calculates BMR and TDEE for female" do
    # BMR = 10×60 + 6.25×165 - 5×25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
    result = Health::TdeeCalculator.new(
      weight_kg: 60, height_cm: 165, age: 25, gender: "female", activity_level: "light"
    ).call
    assert result[:valid]
    assert_equal 1345, result[:bmr]
    assert_equal (1345.25 * 1.375).round(0), result[:tdee]
  end

  # --- All activity levels ---

  test "very active activity level" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "very_active"
    ).call
    assert result[:valid]
    assert_equal (1780 * 1.9).round(0), result[:tdee]
    assert_equal "Extra active (very hard exercise/physical job)", result[:activity_label]
  end

  test "active activity level" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "active"
    ).call
    assert result[:valid]
    assert_equal (1780 * 1.725).round(0), result[:tdee]
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 0, height_cm: 180, age: 30, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero height returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 0, age: 30, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "zero age returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 0, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "age over 120 returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 121, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be realistic (1-120)"
  end

  test "invalid gender returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "other", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Gender must be male or female"
  end

  test "invalid activity level returns error" do
    result = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "extreme"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid activity level"
  end

  test "errors accessor returns empty array before call" do
    calc = Health::TdeeCalculator.new(
      weight_kg: 80, height_cm: 180, age: 30, gender: "male", activity_level: "sedentary"
    )
    assert_equal [], calc.errors
  end
end
