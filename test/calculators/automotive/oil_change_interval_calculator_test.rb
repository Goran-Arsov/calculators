require "test_helper"

class Automotive::OilChangeIntervalCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: full synthetic, normal conditions ---

  test "full synthetic normal: 7500 mile interval" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "full_synthetic",
      current_mileage: 45_000,
      last_change_mileage: 40_000,
      last_change_date: (Date.today - 90).to_s,
      daily_miles: 30,
      driving_conditions: "normal"
    ).call
    assert result[:valid]
    assert_equal 7_500, result[:recommended_interval_miles]
    assert_equal 12, result[:recommended_interval_months]
    assert_equal 5_000, result[:miles_since_last_change].to_i
    assert_equal 2_500, result[:miles_remaining].to_i
    refute result[:overdue]
  end

  # --- Conventional oil, severe conditions ---

  test "conventional severe: 1500 mile interval" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "conventional",
      current_mileage: 25_000,
      last_change_mileage: 24_000,
      last_change_date: (Date.today - 30).to_s,
      daily_miles: 20,
      driving_conditions: "severe"
    ).call
    assert result[:valid]
    assert_equal 1_500, result[:recommended_interval_miles]
    assert_equal 2, result[:recommended_interval_months]
    refute result[:overdue]
  end

  # --- Overdue by mileage ---

  test "overdue when miles exceeded" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "conventional",
      current_mileage: 30_000,
      last_change_mileage: 25_000,
      last_change_date: (Date.today - 60).to_s,
      daily_miles: 30,
      driving_conditions: "normal"
    ).call
    assert result[:valid]
    # 5000 miles since, 3000 mile interval for conventional
    assert result[:overdue]
    assert_equal 0, result[:miles_remaining].to_i
  end

  # --- Validation errors ---

  test "zero current mileage returns error" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "full_synthetic",
      current_mileage: 0,
      last_change_mileage: 0,
      last_change_date: Date.today.to_s,
      daily_miles: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Current mileage must be positive"
  end

  test "current less than last change returns error" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "full_synthetic",
      current_mileage: 30_000,
      last_change_mileage: 35_000,
      last_change_date: Date.today.to_s,
      daily_miles: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Current mileage must be greater than last change mileage"
  end

  test "invalid oil type returns error" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "motor_oil",
      current_mileage: 45_000,
      last_change_mileage: 40_000,
      last_change_date: Date.today.to_s,
      daily_miles: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Oil type must be conventional, synthetic_blend, full_synthetic, or high_mileage"
  end

  test "missing date returns error" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "full_synthetic",
      current_mileage: 45_000,
      last_change_mileage: 40_000,
      last_change_date: "",
      daily_miles: 30
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Last change date is required"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::OilChangeIntervalCalculator.new(
      oil_type: "full_synthetic",
      current_mileage: "45000",
      last_change_mileage: "40000",
      last_change_date: Date.today.to_s,
      daily_miles: "30"
    ).call
    assert result[:valid]
  end
end
