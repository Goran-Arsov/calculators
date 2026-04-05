require "test_helper"

class Construction::PricePerSqmCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: sqm input ---

  test "$300k for 85 sqm = $3529.41/sqm" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85, unit: "sqm"
    ).call

    assert result[:valid]
    assert_in_delta 3_529.41, result[:price_per_sqm], 0.01
  end

  test "price per sqft from sqm input" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85, unit: "sqm"
    ).call

    assert result[:valid]
    # price_per_sqft = 300000 / (85 * 10.7639) = 300000 / 914.93 = 327.88
    assert_in_delta 327.88, result[:price_per_sqft], 0.1
  end

  test "price per acre from sqm input" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85, unit: "sqm"
    ).call

    assert result[:valid]
    # area_acres = 85 / 4046.8564224 = 0.021
    # price_per_acre = 300000 / 0.021 = 14,283,753
    assert result[:price_per_acre] > 10_000_000
  end

  # --- Happy path: sqft input ---

  test "$400k for 2000 sqft converted to sqm price" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 400_000, area: 2000, unit: "sqft"
    ).call

    assert result[:valid]
    # area_sqm = 2000 / 10.7639 = 185.806
    # price_per_sqm = 400000 / 185.806 = 2152.78
    assert_in_delta 2_152.78, result[:price_per_sqm], 0.5
  end

  test "price per sqft from sqft input" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 400_000, area: 2000, unit: "sqft"
    ).call

    assert result[:valid]
    assert_equal 200.0, result[:price_per_sqft]
  end

  # --- Area conversions ---

  test "area conversions sqm to sqft" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 100_000, area: 100, unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:area_sqm]
    assert_in_delta 1_076.39, result[:area_sqft], 0.1
  end

  test "area conversions sqft to sqm" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 100_000, area: 1076.39, unit: "sqft"
    ).call

    assert result[:valid]
    assert_in_delta 100.0, result[:area_sqm], 0.1
    assert_in_delta 1_076.39, result[:area_sqft], 0.01
  end

  test "area in acres for 1 acre sqm equivalent" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 100_000, area: 4046.86, unit: "sqm"
    ).call

    assert result[:valid]
    assert_in_delta 1.0, result[:area_acres], 0.001
  end

  # --- Default unit ---

  test "default unit is sqm" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 100_000, area: 50
    ).call

    assert result[:valid]
    assert_equal 2_000.0, result[:price_per_sqm]
  end

  # --- Total cost is returned ---

  test "total cost is returned" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85, unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 300_000.0, result[:total_cost]
  end

  # --- Validation errors ---

  test "zero cost returns error" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 0, area: 85, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "negative cost returns error" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: -50_000, area: 85, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "zero area returns error" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 0, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "negative area returns error" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: -50, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "invalid unit returns error" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85, unit: "acres"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Unit must be sqm or sqft"
  end

  # --- Multiple errors ---

  test "multiple validation errors at once" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 0, area: 0, unit: "invalid"
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: "300000", area: "85", unit: "sqm"
    ).call

    assert result[:valid]
    assert_in_delta 3_529.41, result[:price_per_sqm], 0.01
  end

  # --- Edge cases ---

  test "very large area" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 10_000_000, area: 100_000, unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 100.0, result[:price_per_sqm]
    assert result[:area_acres] > 0
  end

  test "small room area" do
    result = Construction::PricePerSqmCalculator.new(
      total_cost: 5_000, area: 20, unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 250.0, result[:price_per_sqm]
  end

  # --- Errors accessor ---

  test "errors accessor returns empty array before call" do
    calc = Construction::PricePerSqmCalculator.new(
      total_cost: 300_000, area: 85
    )
    assert_equal [], calc.errors
  end
end
