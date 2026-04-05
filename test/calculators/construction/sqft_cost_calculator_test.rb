require "test_helper"

class Construction::SqftCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$400k for 2000 sqft → $200/sqft" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 400_000, area_sqft: 2000
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:cost_per_sqft]
  end

  test "cost per sqm is higher than cost per sqft" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 400_000, area_sqft: 2000
    ).call

    assert result[:valid]
    assert result[:cost_per_sqm] > result[:cost_per_sqft]
    # cost per sqm = 200 * 10.7639 = 2152.78
    assert_in_delta 2_152.78, result[:cost_per_sqm], 0.1
  end

  test "area conversions are correct" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 100_000, area_sqft: 43_560
    ).call

    assert result[:valid]
    assert_in_delta 1.0, result[:area_acres], 0.001
    assert_in_delta 4_046.86, result[:area_sqm], 0.5
  end

  test "cost per acre calculated correctly" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 100_000, area_sqft: 43_560
    ).call

    assert result[:valid]
    assert_in_delta 100_000.0, result[:cost_per_acre], 0.01
  end

  # --- Small area ---

  test "small area like a room" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 5_000, area_sqft: 200
    ).call

    assert result[:valid]
    assert_equal 25.0, result[:cost_per_sqft]
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 0, area_sqft: 2000
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "error when area is zero" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 400_000, area_sqft: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "error when area is negative" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 400_000, area_sqft: -100
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "multiple errors at once" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 0, area_sqft: 0
    ).call

    refute result[:valid]
    assert_equal 2, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Construction::SqftCostCalculator.new(
      total_cost: "400000", area_sqft: "2000"
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:cost_per_sqft]
  end

  # --- Edge cases ---

  test "very large area" do
    result = Construction::SqftCostCalculator.new(
      total_cost: 10_000_000, area_sqft: 100_000
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:cost_per_sqft]
    assert result[:area_acres] > 0
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SqftCostCalculator.new(
      total_cost: 400_000, area_sqft: 2000
    )
    assert_equal [], calc.errors
  end
end
