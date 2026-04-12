require "test_helper"

class Cooking::MealPrepCostCalculatorTest < ActiveSupport::TestCase
  test "happy path: simple recipe" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: 4,
      ingredients: [
        { name: "Chicken", cost: 10, quantity_used: 2, quantity_purchased: 5 },
        { name: "Rice", cost: 3, quantity_used: 1, quantity_purchased: 3 }
      ]
    )
    result = calc.call

    assert result[:valid]
    # Chicken: 10/5 * 2 = 4, Rice: 3/3 * 1 = 1, Total: 5
    assert_equal 5.0, result[:total_cost]
    assert_equal 1.25, result[:cost_per_serving]
  end

  test "happy path: single ingredient" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: 2,
      ingredients: [
        { name: "Pasta", cost: 2, quantity_used: 1, quantity_purchased: 1 }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 2.0, result[:total_cost]
    assert_equal 1.0, result[:cost_per_serving]
  end

  test "zero servings returns error" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: 0,
      ingredients: [ { name: "Flour", cost: 3, quantity_used: 1, quantity_purchased: 1 } ]
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Servings must be positive"
  end

  test "empty ingredients returns error" do
    calc = Cooking::MealPrepCostCalculator.new(servings: 4, ingredients: [])
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "At least one ingredient is required"
  end

  test "zero cost ingredient returns error" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: 4,
      ingredients: [ { name: "Water", cost: 0, quantity_used: 1, quantity_purchased: 1 } ]
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("cost must be positive") }
  end

  test "daily and weekly costs calculated" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: 4,
      ingredients: [
        { name: "Food", cost: 20, quantity_used: 1, quantity_purchased: 1 }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5.0, result[:cost_per_serving]
    assert_equal 15.0, result[:daily_cost_3_meals]
  end

  test "string inputs are coerced" do
    calc = Cooking::MealPrepCostCalculator.new(
      servings: "4",
      ingredients: [
        { name: "Item", cost: "10", quantity_used: "2", quantity_purchased: "5" }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 4.0, result[:total_cost]
  end
end
