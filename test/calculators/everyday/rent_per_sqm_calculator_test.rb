require "test_helper"

class Everyday::RentPerSqmCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: square meters ---

  test "$1500/month for 75 sqm → $20/sqm" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1500, area: 75, unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 20.0, result[:price_per_sqm]
    assert_equal 18_000.0, result[:annual_cost]
  end

  test "price per sqft is less than price per sqm" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1500, area: 75, unit: "sqm"
    ).call

    assert result[:valid]
    assert result[:price_per_sqft] < result[:price_per_sqm]
  end

  # --- Happy path: square feet ---

  test "input in sqft converts to sqm correctly" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 2000, area: 1000, unit: "sqft"
    ).call

    assert result[:valid]
    assert_in_delta 92.90, result[:area_sqm], 0.1
    assert_equal 2.0, result[:price_per_sqft]
  end

  test "area conversion is bidirectional" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1000, area: 50, unit: "sqm"
    ).call

    assert result[:valid]
    assert_in_delta 50.0 * 10.7639, result[:area_sqft], 0.1
    assert_equal 50.0, result[:area_sqm]
  end

  # --- Validation errors ---

  test "error when monthly rent is zero" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 0, area: 75, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Monthly rent must be greater than zero"
  end

  test "error when area is negative" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1500, area: -10, unit: "sqm"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "error when unit is invalid" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1500, area: 75, unit: "acres"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Unit must be sqm or sqft"
  end

  test "multiple errors at once" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 0, area: 0, unit: "invalid"
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: "1500", area: "75", unit: "sqm"
    ).call

    assert result[:valid]
    assert_equal 20.0, result[:price_per_sqm]
  end

  # --- Edge cases ---

  test "annual cost is 12 times monthly rent" do
    result = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1234.56, area: 80, unit: "sqm"
    ).call

    assert result[:valid]
    assert_in_delta 1234.56 * 12, result[:annual_cost], 0.01
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::RentPerSqmCalculator.new(
      monthly_rent: 1500, area: 75, unit: "sqm"
    )
    assert_equal [], calc.errors
  end
end
