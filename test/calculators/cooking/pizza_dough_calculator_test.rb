require "test_helper"

class Cooking::PizzaDoughCalculatorTest < ActiveSupport::TestCase
  test "happy path: 4 medium pizzas at 65% hydration" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65)
    result = calc.call

    assert result[:valid]
    assert_equal 4, result[:num_pizzas]
    assert_equal 65.0, result[:hydration_pct]
    assert_equal 1000, result[:total_dough_weight]
    assert result[:flour_g] > 0
    assert result[:water_g] > 0
    assert result[:salt_g] > 0
    assert result[:yeast_g] > 0
    # Water should be ~65% of flour
    actual_hydration = result[:water_g] / result[:flour_g]
    assert_in_delta 0.65, actual_hydration, 0.01
  end

  test "happy path: 2 large pizzas" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 2, size: "large", hydration: 70)
    result = calc.call

    assert result[:valid]
    assert_equal 600, result[:total_dough_weight]
    assert_equal 300, result[:dough_ball_weight]
  end

  test "same day dough uses more yeast" do
    same_day = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65, ferment_time: "same_day")
    cold_48h = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65, ferment_time: "cold_48h")

    assert same_day.call[:yeast_g] > cold_48h.call[:yeast_g]
  end

  test "oil is included by default" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65)
    result = calc.call

    assert result[:valid]
    assert result[:oil_g] > 0
  end

  test "oil excluded when include_oil is false" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65, include_oil: false)
    result = calc.call

    assert result[:valid]
    assert_equal 0.0, result[:oil_g]
  end

  test "zero pizzas returns error" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 0, size: "medium", hydration: 65)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Number of pizzas must be positive"
  end

  test "unknown size returns error" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "jumbo", hydration: 65)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Unknown pizza size: jumbo"
  end

  test "hydration too low returns error" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 40)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hydration must be between 50% and 100%"
  end

  test "hydration too high returns error" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 110)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hydration must be between 50% and 100%"
  end

  test "realistic flour amount for 4 medium pizzas" do
    calc = Cooking::PizzaDoughCalculator.new(num_pizzas: 4, size: "medium", hydration: 65)
    result = calc.call

    # 4 x 250g = 1000g total dough
    # Flour should be roughly 580-600g
    assert_in_delta 590, result[:flour_g], 20
  end
end
