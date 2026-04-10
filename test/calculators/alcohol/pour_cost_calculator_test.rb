require "test_helper"

class Alcohol::PourCostCalculatorTest < ActiveSupport::TestCase
  test "typical 750ml bottle at 1.5 oz pour" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5,
      sale_price: 9, target_pour_cost_pct: 20
    ).call
    assert_equal true, result[:valid]
    # 750 mL = 25.36 oz; pours = 25.36 / 1.5 = 16.9
    assert_in_delta 16.9, result[:pours_per_bottle], 0.1
    # Cost per pour = 22 / 25.36 * 1.5 ≈ 1.30
    assert_in_delta 1.30, result[:cost_per_pour], 0.01
    # Pour cost % = 1.30 / 9 * 100 ≈ 14.5%
    assert_in_delta 14.5, result[:pour_cost_pct], 0.2
  end

  test "profit per pour and bottle" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5, sale_price: 9
    ).call
    # Profit = 9 - 1.30 = 7.70
    assert_in_delta 7.70, result[:profit_per_pour], 0.02
    # Profit per bottle = 7.70 * 16.9 ≈ 130
    assert_in_delta 130, result[:profit_per_bottle], 1
  end

  test "suggested sale price hits target pour cost" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5,
      sale_price: 9, target_pour_cost_pct: 20
    ).call
    # Suggested = 1.30 / 0.20 = 6.50
    assert_in_delta 6.50, result[:suggested_sale_price], 0.05
  end

  test "gross margin is 100 minus pour cost" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5, sale_price: 9
    ).call
    assert_in_delta 100 - result[:pour_cost_pct], result[:gross_margin_pct], 0.1
  end

  test "rating for excellent pour cost" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5, sale_price: 9
    ).call
    assert_match(/excellent/i, result[:rating])
  end

  test "rating for poor pour cost" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5, sale_price: 4
    ).call
    assert_match(/poor|below/i, result[:rating])
  end

  test "error when pour size exceeds bottle" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 50, pour_size_oz: 5, sale_price: 9
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Pour size cannot exceed bottle size"
  end

  test "error when bottle cost zero" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 0, bottle_size_ml: 750, pour_size_oz: 1.5, sale_price: 9
    ).call
    assert_equal false, result[:valid]
  end

  test "error when target pct out of range" do
    result = Alcohol::PourCostCalculator.new(
      bottle_cost: 22, bottle_size_ml: 750, pour_size_oz: 1.5,
      sale_price: 9, target_pour_cost_pct: 0
    ).call
    assert_equal false, result[:valid]
  end
end
