require "test_helper"

class Cooking::MacrosPerRecipeCalculatorTest < ActiveSupport::TestCase
  test "happy path: simple recipe" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 4,
      ingredients: [
        { name: "Chicken", calories: 250, protein_g: 30, carbs_g: 0, fat_g: 10, quantity: 2 },
        { name: "Rice", calories: 200, protein_g: 4, carbs_g: 45, fat_g: 1, quantity: 1 }
      ]
    )
    result = calc.call

    assert result[:valid]
    # Total: Chicken 2x(250, 30, 0, 10) + Rice 1x(200, 4, 45, 1)
    # = (500 + 200, 60 + 4, 0 + 45, 20 + 1) = (700, 64, 45, 21)
    assert_equal 700.0, result[:total][:calories]
    assert_equal 64.0, result[:total][:protein_g]
    assert_equal 45.0, result[:total][:carbs_g]
    assert_equal 21.0, result[:total][:fat_g]
    # Per serving: /4
    assert_equal 175.0, result[:per_serving][:calories]
    assert_equal 16.0, result[:per_serving][:protein_g]
  end

  test "macro percentages sum to approximately 100" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 1,
      ingredients: [
        { name: "Mixed", calories: 400, protein_g: 25, carbs_g: 50, fat_g: 12, quantity: 1 }
      ]
    )
    result = calc.call

    assert result[:valid]
    total_pct = result[:macro_percentages][:protein] + result[:macro_percentages][:carbs] + result[:macro_percentages][:fat]
    assert_in_delta 100.0, total_pct, 0.5
  end

  test "protein percentage calculation" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 1,
      ingredients: [
        { name: "Pure protein", calories: 100, protein_g: 25, carbs_g: 0, fat_g: 0, quantity: 1 }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 100.0, result[:macro_percentages][:protein]
    assert_equal 0.0, result[:macro_percentages][:carbs]
    assert_equal 0.0, result[:macro_percentages][:fat]
  end

  test "zero servings returns error" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 0,
      ingredients: [{ name: "Item", calories: 100, protein_g: 10, carbs_g: 10, fat_g: 5, quantity: 1 }]
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Servings must be positive"
  end

  test "empty ingredients returns error" do
    calc = Cooking::MacrosPerRecipeCalculator.new(servings: 4, ingredients: [])
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "At least one ingredient is required"
  end

  test "negative calories returns error" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 4,
      ingredients: [{ name: "Bad", calories: -100, protein_g: 10, carbs_g: 10, fat_g: 5, quantity: 1 }]
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("calories must be non-negative") }
  end

  test "quantity defaults to 1 when zero" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 1,
      ingredients: [{ name: "Item", calories: 100, protein_g: 10, carbs_g: 10, fat_g: 5, quantity: 0 }]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 100.0, result[:total][:calories]
  end

  test "multiple ingredients aggregate correctly" do
    calc = Cooking::MacrosPerRecipeCalculator.new(
      servings: 2,
      ingredients: [
        { name: "A", calories: 100, protein_g: 10, carbs_g: 5, fat_g: 3, quantity: 1 },
        { name: "B", calories: 200, protein_g: 20, carbs_g: 10, fat_g: 6, quantity: 1 },
        { name: "C", calories: 50, protein_g: 5, carbs_g: 2, fat_g: 1, quantity: 2 }
      ]
    )
    result = calc.call

    assert result[:valid]
    # Total: 100 + 200 + 100 = 400
    assert_equal 400.0, result[:total][:calories]
    assert_equal 200.0, result[:per_serving][:calories]
  end
end
