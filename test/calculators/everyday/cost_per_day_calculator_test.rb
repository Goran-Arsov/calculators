require "test_helper"

class Everyday::CostPerDayCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$90 for 30 days = $3/day" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 90, number_of_days: 30).call
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_day]
  end

  test "weekly cost is 7 times daily" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 70, number_of_days: 10).call
    assert_nil result[:errors]
    assert_equal 7.0, result[:cost_per_day]
    assert_equal 49.0, result[:cost_per_week]
  end

  test "monthly cost uses 30.4375 days" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 365.25, number_of_days: 365.25).call
    assert_nil result[:errors]
    assert_equal 1.0, result[:cost_per_day]
    assert_in_delta 30.44, result[:cost_per_month], 0.01
  end

  test "yearly cost uses 365.25 days" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 10, number_of_days: 10).call
    assert_nil result[:errors]
    assert_equal 1.0, result[:cost_per_day]
    assert_equal 365.25, result[:cost_per_year]
  end

  test "single day cost" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 25, number_of_days: 1).call
    assert_nil result[:errors]
    assert_equal 25.0, result[:cost_per_day]
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 0, number_of_days: 30).call
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "error when number of days is zero" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 90, number_of_days: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Number of days must be greater than zero"
  end

  test "error when total cost is negative" do
    result = Everyday::CostPerDayCalculator.new(total_cost: -10, number_of_days: 30).call
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerDayCalculator.new(total_cost: "90", number_of_days: "30").call
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_day]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerDayCalculator.new(total_cost: 90, number_of_days: 30)
    assert_equal [], calc.errors
  end

  test "fractional days" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 10, number_of_days: 0.5).call
    assert_nil result[:errors]
    assert_equal 20.0, result[:cost_per_day]
  end

  test "very large values" do
    result = Everyday::CostPerDayCalculator.new(total_cost: 1_000_000, number_of_days: 365).call
    assert_nil result[:errors]
    assert_in_delta 2739.73, result[:cost_per_day], 0.01
  end
end
