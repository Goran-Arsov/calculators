require "test_helper"

class Alcohol::CocktailAbvCalculatorTest < ActiveSupport::TestCase
  test "manhattan style cocktail stirred" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [
        { volume_oz: 2.0, abv_pct: 40 },
        { volume_oz: 1.0, abv_pct: 16 },
        { volume_oz: 0.25, abv_pct: 0 }
      ],
      method: "stirred"
    ).call
    assert_equal true, result[:valid]
    # Pre dilution: (2*40 + 1*16 + 0) / 3.25 = 96/3.25 = 29.5%
    assert_in_delta 29.54, result[:pre_dilution_abv], 0.1
    # After 22% dilution: 29.54 / 1.22 = 24.2%
    assert_in_delta 24.21, result[:final_abv], 0.1
    assert_equal 22, result[:dilution_pct]
  end

  test "shaken adds more dilution than stirred" do
    ings = [ { volume_oz: 2.0, abv_pct: 40 } ]
    stirred = Alcohol::CocktailAbvCalculator.new(ingredients: ings, method: "stirred").call
    shaken = Alcohol::CocktailAbvCalculator.new(ingredients: ings, method: "shaken").call
    assert shaken[:final_abv] < stirred[:final_abv]
  end

  test "built drink has zero dilution" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 2.0, abv_pct: 40 } ],
      method: "built"
    ).call
    assert_equal 0, result[:dilution_pct]
    assert_in_delta result[:pre_dilution_abv], result[:final_abv], 0.01
  end

  test "non alcoholic ingredient lowers final abv" do
    pure = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 2.0, abv_pct: 40 } ], method: "stirred"
    ).call
    diluted = Alcohol::CocktailAbvCalculator.new(
      ingredients: [
        { volume_oz: 2.0, abv_pct: 40 },
        { volume_oz: 2.0, abv_pct: 0 }
      ],
      method: "stirred"
    ).call
    assert diluted[:final_abv] < pure[:final_abv]
  end

  test "ml conversion of final volume" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 2.0, abv_pct: 40 } ], method: "shaken"
    ).call
    assert_in_delta result[:final_volume_oz] * 29.5735, result[:final_volume_ml], 0.5
  end

  test "standard drinks calculation" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 1.5, abv_pct: 40 } ], method: "built"
    ).call
    # 1.5 oz of 40% spirit = 1.0 standard drink
    assert_in_delta 1.0, result[:standard_drinks_us], 0.05
  end

  test "strength category for strong cocktail" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 2.0, abv_pct: 40 }, { volume_oz: 1.0, abv_pct: 16 } ],
      method: "stirred"
    ).call
    assert_match(/strong/i, result[:strength_category])
  end

  test "error when ingredients empty" do
    result = Alcohol::CocktailAbvCalculator.new(ingredients: [], method: "stirred").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one ingredient is required"
  end

  test "error when method invalid" do
    result = Alcohol::CocktailAbvCalculator.new(
      ingredients: [ { volume_oz: 2, abv_pct: 40 } ], method: "blended"
    ).call
    assert_equal false, result[:valid]
  end
end
