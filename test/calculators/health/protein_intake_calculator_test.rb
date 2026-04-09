require "test_helper"

class Health::ProteinIntakeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: sedentary, maintain ---

  test "sedentary maintain: 70 kg" do
    # base = 0.8, goal_adj = 0, protein_per_kg = 0.8
    # daily = 70 * 0.8 = 56g, per_meal = 14g, calories = 224, pct = 11.2%
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "sedentary", goal: "maintain"
    ).call
    assert result[:valid]
    assert_in_delta 56.0, result[:daily_protein_grams], 0.1
    assert_in_delta 0.8, result[:protein_per_kg], 0.01
    assert_in_delta 14.0, result[:per_meal_grams], 0.1
    assert_in_delta 224, result[:protein_calories], 1
    assert_in_delta 11.2, result[:protein_pct_of_2000cal], 0.1
  end

  # --- Happy path: athlete, muscle_gain ---

  test "athlete muscle gain: 80 kg" do
    # base = 2.0, goal_adj = 0.4, protein_per_kg = 2.4
    # daily = 80 * 2.4 = 192g, per_meal = 48g, calories = 768, pct = 38.4%
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "athlete", goal: "muscle_gain"
    ).call
    assert result[:valid]
    assert_in_delta 192.0, result[:daily_protein_grams], 0.1
    assert_in_delta 2.4, result[:protein_per_kg], 0.01
    assert_in_delta 48.0, result[:per_meal_grams], 0.1
    assert_in_delta 768, result[:protein_calories], 1
    assert_in_delta 38.4, result[:protein_pct_of_2000cal], 0.1
  end

  # --- Happy path: moderately_active, fat_loss ---

  test "moderately active fat loss: 90 kg" do
    # base = 1.2, goal_adj = 0.2, protein_per_kg = 1.4
    # daily = 90 * 1.4 = 126g, per_meal = 31.5g, calories = 504, pct = 25.2%
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 90, activity_level: "moderately_active", goal: "fat_loss"
    ).call
    assert result[:valid]
    assert_in_delta 126.0, result[:daily_protein_grams], 0.1
    assert_in_delta 1.4, result[:protein_per_kg], 0.01
    assert_in_delta 31.5, result[:per_meal_grams], 0.1
    assert_in_delta 504, result[:protein_calories], 1
    assert_in_delta 25.2, result[:protein_pct_of_2000cal], 0.1
  end

  # --- All activity levels ---

  test "lightly active maintain" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "lightly_active", goal: "maintain"
    ).call
    assert result[:valid]
    assert_in_delta 1.0, result[:protein_per_kg], 0.01
    assert_in_delta 70.0, result[:daily_protein_grams], 0.1
  end

  test "very active maintain" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "very_active", goal: "maintain"
    ).call
    assert result[:valid]
    assert_in_delta 1.6, result[:protein_per_kg], 0.01
    assert_in_delta 112.0, result[:daily_protein_grams], 0.1
  end

  # --- Goal adjustments ---

  test "muscle gain adds 0.4 g/kg" do
    maintain = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "sedentary", goal: "maintain"
    ).call
    muscle = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "sedentary", goal: "muscle_gain"
    ).call
    assert_in_delta 0.4, muscle[:protein_per_kg] - maintain[:protein_per_kg], 0.01
  end

  test "fat loss adds 0.2 g/kg" do
    maintain = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "sedentary", goal: "maintain"
    ).call
    fat_loss = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "sedentary", goal: "fat_loss"
    ).call
    assert_in_delta 0.2, fat_loss[:protein_per_kg] - maintain[:protein_per_kg], 0.01
  end

  # --- Per meal calculation ---

  test "per meal is daily divided by 4" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "moderately_active", goal: "maintain"
    ).call
    assert result[:valid]
    assert_in_delta result[:daily_protein_grams] / 4.0, result[:per_meal_grams], 0.1
  end

  # --- Protein calories ---

  test "protein calories equals grams times 4" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 80, activity_level: "moderately_active", goal: "maintain"
    ).call
    assert result[:valid]
    assert_in_delta result[:daily_protein_grams] * 4, result[:protein_calories], 1
  end

  # --- Validation: zero weight ---

  test "zero weight returns error" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 0, activity_level: "sedentary", goal: "maintain"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  # --- Validation: negative weight ---

  test "negative weight returns error" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: -70, activity_level: "sedentary", goal: "maintain"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight must be positive"
  end

  # --- Validation: weight upper bound ---

  test "weight over 500 kg returns error" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 501, activity_level: "sedentary", goal: "maintain"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Weight cannot exceed 500 kg"
  end

  test "weight at 500 kg is accepted" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 500, activity_level: "sedentary", goal: "maintain"
    ).call
    assert result[:valid]
  end

  # --- Validation: invalid activity level ---

  test "invalid activity level returns error" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "extreme", goal: "maintain"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid activity level"
  end

  # --- Validation: invalid goal ---

  test "invalid goal returns error" do
    result = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "sedentary", goal: "bulk_up"
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Invalid goal"
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::ProteinIntakeCalculator.new(
      weight_kg: 70, activity_level: "sedentary", goal: "maintain"
    )
    assert_equal [], calc.errors
  end
end
