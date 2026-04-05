require "test_helper"

class Health::ProteinPerMealCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "150g daily goal, 5 meals = 30g per meal" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 5
    ).call

    assert result[:valid]
    assert_equal 30.0, result[:protein_per_meal]
    assert_equal 5, result[:meals_per_day]
    assert_equal 150.0, result[:daily_protein_goal]
  end

  test "120g daily goal, 4 meals = 30g per meal" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 120, meals_per_day: 4
    ).call

    assert result[:valid]
    assert_equal 30.0, result[:protein_per_meal]
  end

  test "200g daily goal, 3 meals gives non-integer result" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 200, meals_per_day: 3
    ).call

    assert result[:valid]
    assert_in_delta 66.7, result[:protein_per_meal], 0.1
  end

  # --- Distribution classification ---

  test "30g per meal is optimal distribution" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 120, meals_per_day: 4
    ).call

    assert result[:valid]
    assert_equal "optimal", result[:distribution]
  end

  test "20g per meal is optimal distribution (lower boundary)" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 100, meals_per_day: 5
    ).call

    assert result[:valid]
    assert_equal "optimal", result[:distribution]
  end

  test "40g per meal is optimal distribution (upper boundary)" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 120, meals_per_day: 3
    ).call

    assert result[:valid]
    assert_equal "optimal", result[:distribution]
  end

  test "15g per meal is low distribution" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 60, meals_per_day: 4
    ).call

    assert result[:valid]
    assert_equal "low", result[:distribution]
  end

  test "60g per meal is high distribution" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 180, meals_per_day: 3
    ).call

    assert result[:valid]
    assert_equal "high", result[:distribution]
  end

  # --- Protein per meal in ounces ---

  test "protein per meal oz conversion" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 5
    ).call

    assert result[:valid]
    # 30g / 28.35 = 1.058
    assert_in_delta 1.1, result[:protein_per_meal_oz], 0.1
  end

  # --- Recommended min/max ---

  test "recommended min and max are returned" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 5
    ).call

    assert result[:valid]
    assert result[:recommended_min_per_meal] > 0
    assert result[:recommended_max_per_meal] > result[:recommended_min_per_meal]
  end

  # --- Validation errors ---

  test "zero protein goal returns error" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 0, meals_per_day: 4
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Daily protein goal must be positive"
  end

  test "negative protein goal returns error" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: -50, meals_per_day: 4
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Daily protein goal must be positive"
  end

  test "zero meals returns error" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Number of meals must be positive"
  end

  test "negative meals returns error" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: -2
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Number of meals must be positive"
  end

  test "more than 10 meals returns error" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 11
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Number of meals must be at most 10"
  end

  test "10 meals is allowed" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 10
    ).call

    assert result[:valid]
    assert_equal 15.0, result[:protein_per_meal]
  end

  # --- Multiple errors ---

  test "multiple validation errors at once" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 0, meals_per_day: 0
    ).call

    refute result[:valid]
    assert result[:errors].size >= 2
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: "150", meals_per_day: "5"
    ).call

    assert result[:valid]
    assert_equal 30.0, result[:protein_per_meal]
  end

  # --- Edge case: single meal ---

  test "single meal returns full daily goal" do
    result = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 1
    ).call

    assert result[:valid]
    assert_equal 150.0, result[:protein_per_meal]
    assert_equal "high", result[:distribution]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Health::ProteinPerMealCalculator.new(
      daily_protein_goal: 150, meals_per_day: 5
    )
    assert_equal [], calc.errors
  end
end
