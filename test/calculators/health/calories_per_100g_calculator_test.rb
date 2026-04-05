require "test_helper"

class Health::CaloriesPer100gCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "350 cal for 250g = 140 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 250
    ).call

    assert result[:valid]
    assert_equal 140.0, result[:calories_per_100g]
  end

  test "100g input returns same calories" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 200, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:calories_per_100g]
  end

  # --- Calories per oz ---

  test "calories per oz conversion is correct" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 250
    ).call

    assert result[:valid]
    # 350/250 * 28.3495 = 39.69
    assert_in_delta 39.7, result[:calories_per_oz], 0.1
  end

  # --- Calories per gram ---

  test "calories per gram is calculated" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 250
    ).call

    assert result[:valid]
    assert_equal 1.4, result[:calories_per_gram]
  end

  # --- Energy density classifications ---

  test "very low energy density for 50 cal per 100g" do
    # 50 cal for 100g => 50 cal/100g
    result = Health::CaloriesPer100gCalculator.new(
      calories: 50, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "very_low", result[:energy_density]
  end

  test "very low boundary at 60 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 60, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "very_low", result[:energy_density]
  end

  test "low energy density for 100 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 100, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "low", result[:energy_density]
  end

  test "low boundary at 150 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 150, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "low", result[:energy_density]
  end

  test "medium energy density for 250 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 250, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "medium", result[:energy_density]
  end

  test "medium boundary at 400 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 400, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "medium", result[:energy_density]
  end

  test "high energy density for 550 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 550, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "high", result[:energy_density]
  end

  test "high energy density for 401 cal per 100g" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 401, weight_grams: 100
    ).call

    assert result[:valid]
    assert_equal "high", result[:energy_density]
  end

  # --- Original values are preserved ---

  test "original values are returned" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 250
    ).call

    assert result[:valid]
    assert_equal 350.0, result[:original_calories]
    assert_equal 250.0, result[:original_weight_grams]
  end

  # --- Validation: zero values ---

  test "zero calories returns error" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 0, weight_grams: 100
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Calories must be positive"
  end

  test "zero weight returns error" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  # --- Validation: negative values ---

  test "negative calories returns error" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: -100, weight_grams: 250
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Calories must be positive"
  end

  test "negative weight returns error" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: -50
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  # --- Multiple errors ---

  test "multiple validation errors at once" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 0, weight_grams: 0
    ).call

    refute result[:valid]
    assert_equal 2, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: "350", weight_grams: "250"
    ).call

    assert result[:valid]
    assert_equal 140.0, result[:calories_per_100g]
  end

  # --- Edge cases ---

  test "very small weight" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 5, weight_grams: 1
    ).call

    assert result[:valid]
    assert_equal 500.0, result[:calories_per_100g]
    assert_equal "high", result[:energy_density]
  end

  test "very large weight" do
    result = Health::CaloriesPer100gCalculator.new(
      calories: 1000, weight_grams: 10_000
    ).call

    assert result[:valid]
    assert_equal 10.0, result[:calories_per_100g]
    assert_equal "very_low", result[:energy_density]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::CaloriesPer100gCalculator.new(
      calories: 350, weight_grams: 250
    )
    assert_equal [], calc.errors
  end
end
