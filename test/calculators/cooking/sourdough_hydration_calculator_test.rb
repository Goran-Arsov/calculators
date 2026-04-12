require "test_helper"

class Cooking::SourdoughHydrationCalculatorTest < ActiveSupport::TestCase
  test "happy path: standard sourdough loaf" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 900,
      target_hydration: 72,
      starter_percentage: 20,
      starter_hydration: 100,
      salt_percentage: 2
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 517.2, result[:total_flour], 1.0
    assert_in_delta 372.4, result[:total_water], 1.0
    assert_in_delta 103.4, result[:starter_amount], 1.0
    assert_in_delta 10.3, result[:salt], 1.0
    # Starter at 100% hydration: half flour, half water
    assert_in_delta result[:starter_flour], result[:starter_water], 1.0
    # Added flour + starter flour = total flour
    assert_in_delta result[:total_flour], result[:added_flour] + result[:starter_flour], 0.5
    # Added water + starter water = total water
    assert_in_delta result[:total_water], result[:added_water] + result[:starter_water], 0.5
  end

  test "happy path: low hydration" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 500,
      target_hydration: 60,
      starter_percentage: 15,
      starter_hydration: 100,
      salt_percentage: 2
    )
    result = calc.call

    assert result[:valid]
    assert result[:total_flour] > 0
    assert result[:total_water] > 0
    # Hydration check: water/flour should equal target
    actual_hydration = result[:total_water] / result[:total_flour]
    assert_in_delta 0.60, actual_hydration, 0.01
  end

  test "zero dough weight returns error" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 0, target_hydration: 72, starter_percentage: 20
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Total dough weight must be positive"
  end

  test "hydration too high returns error" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 900, target_hydration: 250, starter_percentage: 20
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Target hydration must be between 1% and 200%"
  end

  test "starter percentage too high returns error" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 900, target_hydration: 72, starter_percentage: 150
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Starter percentage must be between 1% and 100%"
  end

  test "string inputs are coerced" do
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: "900", target_hydration: "72", starter_percentage: "20"
    )
    result = calc.call

    assert result[:valid]
    assert result[:total_flour] > 0
  end

  test "different starter hydration affects flour/water split" do
    # At 50% starter hydration, starter has 2/3 flour and 1/3 water
    calc = Cooking::SourdoughHydrationCalculator.new(
      total_dough_weight: 900,
      target_hydration: 72,
      starter_percentage: 20,
      starter_hydration: 50,
      salt_percentage: 2
    )
    result = calc.call

    assert result[:valid]
    # Starter flour should be more than starter water at 50% hydration
    assert result[:starter_flour] > result[:starter_water]
  end
end
