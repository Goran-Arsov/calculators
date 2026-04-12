require "test_helper"

class Cooking::RecipeScalerCalculatorTest < ActiveSupport::TestCase
  test "happy path: double a recipe" do
    calc = Cooking::RecipeScalerCalculator.new(
      original_servings: 4,
      desired_servings: 8,
      ingredients: [
        { name: "Flour", amount: 2, unit: "cups" },
        { name: "Sugar", amount: 1, unit: "cup" }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 2.0, result[:multiplier]
    assert_equal 4.0, result[:scaled_ingredients][0][:scaled_amount]
    assert_equal 2.0, result[:scaled_ingredients][1][:scaled_amount]
  end

  test "happy path: halve a recipe" do
    calc = Cooking::RecipeScalerCalculator.new(
      original_servings: 8,
      desired_servings: 4,
      ingredients: [
        { name: "Chicken", amount: 3, unit: "lbs" }
      ]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0.5, result[:multiplier]
    assert_equal 1.5, result[:scaled_ingredients][0][:scaled_amount]
  end

  test "same servings yields multiplier of 1" do
    calc = Cooking::RecipeScalerCalculator.new(
      original_servings: 4,
      desired_servings: 4,
      ingredients: [{ name: "Salt", amount: 1, unit: "tsp" }]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 1.0, result[:multiplier]
    assert_equal 1.0, result[:scaled_ingredients][0][:scaled_amount]
  end

  test "zero original servings returns error" do
    calc = Cooking::RecipeScalerCalculator.new(original_servings: 0, desired_servings: 4)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Original servings must be positive"
  end

  test "zero desired servings returns error" do
    calc = Cooking::RecipeScalerCalculator.new(original_servings: 4, desired_servings: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Desired servings must be positive"
  end

  test "negative servings returns error" do
    calc = Cooking::RecipeScalerCalculator.new(original_servings: -1, desired_servings: 4)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Original servings must be positive"
  end

  test "string inputs are coerced" do
    calc = Cooking::RecipeScalerCalculator.new(
      original_servings: "4",
      desired_servings: "12",
      ingredients: [{ name: "Butter", amount: "0.5", unit: "cup" }]
    )
    result = calc.call

    assert result[:valid]
    assert_equal 3.0, result[:multiplier]
    assert_equal 1.5, result[:scaled_ingredients][0][:scaled_amount]
  end

  test "empty ingredients list still works" do
    calc = Cooking::RecipeScalerCalculator.new(original_servings: 4, desired_servings: 8, ingredients: [])
    result = calc.call

    assert result[:valid]
    assert_empty result[:scaled_ingredients]
  end
end
