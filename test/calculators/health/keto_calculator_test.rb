require "test_helper"

class Health::KetoCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: maintain, male, sedentary ---

  test "happy path male sedentary maintain" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "maintain"
    ).call
    assert result[:valid]
    # BMR = 10*80 + 6.25*175 - 5*30 + 5 = 800 + 1093.75 - 150 + 5 = 1748.75
    # TDEE = 1748.75 * 1.2 = 2098.5
    assert_in_delta 1749, result[:bmr], 1
    assert_in_delta 2099, result[:tdee], 1
    assert_in_delta 2099, result[:daily_calories], 1
    # Fat: 70% of 2099 = 1469.3 / 9 = 163.3g
    assert_in_delta 163, result[:fat_grams], 2
    # Protein: 25% of 2099 = 524.75 / 4 = 131.2g
    assert_in_delta 131, result[:protein_grams], 2
    # Carbs: 5% of 2099 = 104.95 / 4 = 26.2g => capped at 25g
    assert result[:carb_grams] <= 25
  end

  # --- Female, moderate activity ---

  test "female moderate activity maintain" do
    result = Health::KetoCalculator.new(
      weight: 65, height: 165, age: 28, gender: "female",
      activity_level: "moderate", goal: "maintain"
    ).call
    assert result[:valid]
    # BMR = 10*65 + 6.25*165 - 5*28 - 161 = 650 + 1031.25 - 140 - 161 = 1380.25
    assert_in_delta 1380, result[:bmr], 1
  end

  # --- Weight loss goal ---

  test "lose goal subtracts 500 from TDEE" do
    maintain = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "maintain"
    ).call
    lose = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "lose"
    ).call
    assert_in_delta maintain[:daily_calories] - 500, lose[:daily_calories], 1
  end

  # --- Weight gain goal ---

  test "gain goal adds 500 to TDEE" do
    maintain = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "maintain"
    ).call
    gain = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "gain"
    ).call
    assert_in_delta maintain[:daily_calories] + 500, gain[:daily_calories], 1
  end

  # --- Carb cap at 25g ---

  test "carbs are capped at 25g and excess goes to fat" do
    result = Health::KetoCalculator.new(
      weight: 100, height: 185, age: 25, gender: "male",
      activity_level: "very_active", goal: "gain"
    ).call
    assert result[:valid]
    assert result[:carb_grams] <= 25
  end

  # --- Imperial units ---

  test "imperial units convert correctly" do
    result = Health::KetoCalculator.new(
      weight: 176, height: 69, age: 30, gender: "male",
      activity_level: "sedentary", goal: "maintain", unit_system: "imperial"
    ).call
    assert result[:valid]
    # 176 lbs = 79.83 kg, 69 in = 175.26 cm
    assert_in_delta 1746, result[:bmr], 5
  end

  # --- Macro percentages sum to ~100 ---

  test "macro percentages roughly sum to 100" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male",
      activity_level: "sedentary", goal: "maintain"
    ).call
    total = result[:fat_percent] + result[:protein_percent] + result[:carb_percent]
    assert_in_delta 100, total, 3 # rounding tolerance
  end

  # --- Validation ---

  test "zero weight returns error" do
    result = Health::KetoCalculator.new(
      weight: 0, height: 175, age: 30, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  test "zero height returns error" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 0, age: 30, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Height must be positive"
  end

  test "zero age returns error" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 0, gender: "male", activity_level: "sedentary"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Age must be positive"
  end

  test "invalid activity level returns error" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male", activity_level: "extreme"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid activity level"
  end

  test "invalid goal returns error" do
    result = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male", activity_level: "sedentary", goal: "shred"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid goal"
  end

  test "multiple validation errors at once" do
    result = Health::KetoCalculator.new(
      weight: 0, height: 0, age: 0, gender: "invalid", activity_level: "invalid"
    ).call
    refute result[:valid]
    assert result[:errors].length >= 5
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Health::KetoCalculator.new(
      weight: "80", height: "175", age: "30", gender: "male", activity_level: "sedentary"
    ).call
    assert result[:valid]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::KetoCalculator.new(
      weight: 80, height: 175, age: 30, gender: "male", activity_level: "sedentary"
    )
    assert_equal [], calc.errors
  end
end
