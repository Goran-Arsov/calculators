require "test_helper"

class Health::CaloriesPerServingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: basic calories only ---

  test "2400 calories, 6 servings = 400 per serving" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 2400, servings: 6
    ).call

    assert result[:valid]
    assert_equal 400.0, result[:calories_per_serving]
  end

  test "1000 calories, 4 servings = 250 per serving" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4
    ).call

    assert result[:valid]
    assert_equal 250.0, result[:calories_per_serving]
  end

  # --- Happy path: with macronutrients ---

  test "macros are divided by servings" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 2400, servings: 6,
      total_protein: 120, total_carbs: 180, total_fat: 60
    ).call

    assert result[:valid]
    assert_equal 20.0, result[:protein_per_serving]
    assert_equal 30.0, result[:carbs_per_serving]
    assert_equal 10.0, result[:fat_per_serving]
  end

  test "macro calorie contributions are correct" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 2400, servings: 6,
      total_protein: 120, total_carbs: 180, total_fat: 60
    ).call

    assert result[:valid]
    # protein: 20g * 4 = 80 cal
    assert_equal 80.0, result[:protein_calories_per_serving]
    # carbs: 30g * 4 = 120 cal
    assert_equal 120.0, result[:carbs_calories_per_serving]
    # fat: 10g * 9 = 90 cal
    assert_equal 90.0, result[:fat_calories_per_serving]
  end

  # --- Happy path: zero macros (optional fields) ---

  test "zero macros when not provided" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 500, servings: 2
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:protein_per_serving]
    assert_equal 0.0, result[:carbs_per_serving]
    assert_equal 0.0, result[:fat_per_serving]
  end

  # --- Fractional results ---

  test "non-integer calories per serving" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 3
    ).call

    assert result[:valid]
    assert_in_delta 333.3, result[:calories_per_serving], 0.1
  end

  # --- Total servings ---

  test "total servings is returned" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4
    ).call

    assert result[:valid]
    assert_equal 4, result[:total_servings]
  end

  # --- Validation: zero values ---

  test "zero calories returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 0, servings: 4
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total calories must be positive"
  end

  test "zero servings returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Number of servings must be positive"
  end

  # --- Validation: negative values ---

  test "negative calories returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: -500, servings: 4
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total calories must be positive"
  end

  test "negative servings returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: -2
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Number of servings must be positive"
  end

  test "negative protein returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4, total_protein: -10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total protein cannot be negative"
  end

  test "negative carbs returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4, total_carbs: -5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total carbs cannot be negative"
  end

  test "negative fat returns error" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4, total_fat: -3
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total fat cannot be negative"
  end

  # --- Multiple errors ---

  test "multiple validation errors at once" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 0, servings: 0, total_protein: -1, total_carbs: -1, total_fat: -1
    ).call

    refute result[:valid]
    assert_equal 5, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: "2400", servings: "6",
      total_protein: "120", total_carbs: "180", total_fat: "60"
    ).call

    assert result[:valid]
    assert_equal 400.0, result[:calories_per_serving]
    assert_equal 20.0, result[:protein_per_serving]
  end

  # --- Edge cases: very large values ---

  test "very large calorie count" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 50_000, servings: 100
    ).call

    assert result[:valid]
    assert_equal 500.0, result[:calories_per_serving]
  end

  # --- Edge case: single serving ---

  test "single serving returns total calories" do
    result = Health::CaloriesPerServingCalculator.new(
      total_calories: 350, servings: 1, total_protein: 25, total_carbs: 40, total_fat: 10
    ).call

    assert result[:valid]
    assert_equal 350.0, result[:calories_per_serving]
    assert_equal 25.0, result[:protein_per_serving]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::CaloriesPerServingCalculator.new(
      total_calories: 1000, servings: 4
    )
    assert_equal [], calc.errors
  end
end
