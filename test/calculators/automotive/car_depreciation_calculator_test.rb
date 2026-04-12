require "test_helper"

class Automotive::CarDepreciationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: new car ---

  test "happy path: new car depreciates correctly" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: 0,
      annual_depreciation_rate: 15, holding_years: 5
    ).call
    assert result[:valid]
    assert_in_delta 35_000.0, result[:current_value], 0.01
    assert result[:future_value] > 0
    assert result[:future_value] < 35_000
    assert_equal 5, result[:schedule].length
    # First year: 20% (new car), then 15% per year
    assert_in_delta 7_000.0, result[:schedule][0][:depreciation], 0.01
  end

  # --- Used car ---

  test "happy path: 3-year-old car" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: 3,
      annual_depreciation_rate: 15, holding_years: 3
    ).call
    assert result[:valid]
    # Year 1: 15% off 35000 = 29750, Year 2: 15% off 29750 = 25287.5, Year 3: 15% off 25287.5 = 21494.375
    assert_in_delta 21_494.38, result[:current_value], 1.0
    assert result[:future_value] < result[:current_value]
    assert_equal 3, result[:schedule].length
  end

  # --- Validation: zero price ---

  test "zero purchase price returns error" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 0, vehicle_age_years: 0,
      annual_depreciation_rate: 15, holding_years: 5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Purchase price must be positive"
  end

  # --- Validation: negative age ---

  test "negative vehicle age returns error" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: -1,
      annual_depreciation_rate: 15, holding_years: 5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Vehicle age cannot be negative"
  end

  # --- Validation: zero holding years ---

  test "zero holding years returns error" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: 0,
      annual_depreciation_rate: 15, holding_years: 0
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Holding years must be positive"
  end

  # --- Validation: rate out of range ---

  test "depreciation rate over 100% returns error" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: 0,
      annual_depreciation_rate: 150, holding_years: 5
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Depreciation rate must be between 0 and 100"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: "35000", vehicle_age_years: "0",
      annual_depreciation_rate: "15", holding_years: "5"
    ).call
    assert result[:valid]
    assert result[:future_value] > 0
  end

  # --- Zero depreciation rate ---

  test "zero depreciation rate preserves value" do
    result = Automotive::CarDepreciationCalculator.new(
      purchase_price: 35_000, vehicle_age_years: 0,
      annual_depreciation_rate: 0, holding_years: 3
    ).call
    assert result[:valid]
    # First year still has 20% for new car, then 0% after
    assert_in_delta 28_000.0, result[:future_value], 0.01
  end
end
