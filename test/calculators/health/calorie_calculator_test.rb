require "test_helper"

class Health::CalorieCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: metric male ---

  test "happy path metric male sedentary" do
    # Mifflin-St Jeor: BMR = 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780
    # TDEE = 1780 * 1.2 = 2136
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call

    assert result[:valid]
    assert_equal 1780, result[:bmr]
    assert_equal 2136, result[:tdee]
    assert_equal 1886, result[:mild_loss]
    assert_equal 1636, result[:weight_loss]
    assert_equal 2386, result[:mild_gain]
    assert_equal 2636, result[:weight_gain]
  end

  test "happy path metric female moderate" do
    # BMR = 10*60 + 6.25*165 - 5*25 - 161 = 600 + 1031.25 - 125 - 161 = 1345.25
    # TDEE = 1345.25 * 1.55 = 2085.1375
    result = Health::CalorieCalculator.new(
      age: 25, sex: "female", weight: 60, height: 165,
      activity_level: "moderate", unit_system: "metric"
    ).call

    assert result[:valid]
    assert_equal 1345, result[:bmr]
    assert_equal 2085, result[:tdee]
  end

  # --- Activity levels ---

  test "light activity level" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "light", unit_system: "metric"
    ).call
    assert result[:valid]
    expected_tdee = (1780 * 1.375).round(0)
    assert_equal expected_tdee, result[:tdee]
  end

  test "active activity level" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "active", unit_system: "metric"
    ).call
    assert result[:valid]
    expected_tdee = (1780 * 1.725).round(0)
    assert_equal expected_tdee, result[:tdee]
  end

  test "very active activity level" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "very_active", unit_system: "metric"
    ).call
    assert result[:valid]
    expected_tdee = (1780 * 1.9).round(0)
    assert_equal expected_tdee, result[:tdee]
  end

  # --- Calorie adjustment fields ---

  test "calorie adjustments are 250 and 500 from tdee" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    assert result[:valid]
    assert_equal result[:tdee] - 250, result[:mild_loss]
    assert_equal result[:tdee] - 500, result[:weight_loss]
    assert_equal result[:tdee] + 250, result[:mild_gain]
    assert_equal result[:tdee] + 500, result[:weight_gain]
  end

  # --- Happy path: imperial ---

  test "happy path imperial male" do
    # weight_kg = 176 * 0.453592 = 79.832192
    # height_cm = 70 * 2.54 = 177.8
    # BMR = 10*79.832192 + 6.25*177.8 - 5*30 + 5
    #     = 798.32192 + 1111.25 - 150 + 5 = 1764.57
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 176, height: 70,
      activity_level: "sedentary", unit_system: "imperial"
    ).call

    assert result[:valid]
    assert_in_delta 1765, result[:bmr], 2
  end

  test "happy path imperial female" do
    # weight_kg = 132 * 0.453592 = 59.874144
    # height_cm = 65 * 2.54 = 165.1
    # BMR = 10*59.874144 + 6.25*165.1 - 5*25 - 161
    #     = 598.74 + 1031.875 - 125 - 161 = 1343.62
    result = Health::CalorieCalculator.new(
      age: 25, sex: "female", weight: 132, height: 65,
      activity_level: "moderate", unit_system: "imperial"
    ).call

    assert result[:valid]
    assert_in_delta 1344, result[:bmr], 2
  end

  # --- Default unit system ---

  test "default unit system is metric" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary"
    ).call
    assert result[:valid]
    assert_equal 1780, result[:bmr]
  end

  # --- Edge cases: age ---

  test "young person (age 18)" do
    # BMR = 10*70 + 6.25*175 - 5*18 + 5 = 700 + 1093.75 - 90 + 5 = 1708.75
    result = Health::CalorieCalculator.new(
      age: 18, sex: "male", weight: 70, height: 175,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    assert result[:valid]
    assert_equal 1709, result[:bmr]
  end

  test "elderly person (age 80)" do
    # BMR = 10*70 + 6.25*175 - 5*80 + 5 = 700 + 1093.75 - 400 + 5 = 1398.75
    result = Health::CalorieCalculator.new(
      age: 80, sex: "male", weight: 70, height: 175,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    assert result[:valid]
    assert_equal 1399, result[:bmr]
  end

  # --- Validation: zero values ---

  test "zero age returns error" do
    result = Health::CalorieCalculator.new(
      age: 0, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "zero weight returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 0, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero height returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 0,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: negative values ---

  test "negative age returns error" do
    result = Health::CalorieCalculator.new(
      age: -5, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "negative weight returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: -80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "negative height returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: -180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  # --- Validation: invalid fields ---

  test "invalid sex returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "other", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Sex must be male or female"
  end

  test "invalid activity level returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "extreme", unit_system: "metric"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid activity level"
  end

  test "invalid unit system returns error" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary", unit_system: "stones"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    result = Health::CalorieCalculator.new(
      age: 0, sex: "other", weight: 0, height: 0,
      activity_level: "extreme", unit_system: "stones"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
    assert_includes result[:errors], "Sex must be male or female"
    assert_includes result[:errors], "Weight must be positive"
    assert_includes result[:errors], "Height must be positive"
    assert_includes result[:errors], "Invalid activity level"
    assert_includes result[:errors], "Invalid unit system"
  end

  # --- Very large values ---

  test "very large weight metric" do
    result = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 500, height: 200,
      activity_level: "sedentary", unit_system: "metric"
    ).call
    assert result[:valid]
    assert result[:bmr] > 0
    assert result[:tdee] > result[:bmr]
  end

  test "errors accessor returns empty array before call" do
    calc = Health::CalorieCalculator.new(
      age: 30, sex: "male", weight: 80, height: 180,
      activity_level: "sedentary"
    )
    assert_equal [], calc.errors
  end
end
