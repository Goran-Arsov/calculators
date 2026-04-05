require "test_helper"

class Everyday::CostPerHourCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "$24 for 8 hours = $3/hour" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 24, number_of_hours: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_hour]
  end

  test "cost per minute is hourly divided by 60" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 60, number_of_hours: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 60.0, result[:cost_per_hour]
    assert_equal 1.0, result[:cost_per_minute]
  end

  test "cost per 8-hour day" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 10, number_of_hours: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10.0, result[:cost_per_hour]
    assert_equal 80.0, result[:cost_per_8_hours]
  end

  test "cost per 24 hours" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 10, number_of_hours: 1).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 240.0, result[:cost_per_day]
  end

  test "fractional hours" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 15, number_of_hours: 1.5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 10.0, result[:cost_per_hour]
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 0, number_of_hours: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  test "error when number of hours is zero" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 24, number_of_hours: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of hours must be greater than zero"
  end

  test "error when total cost is negative" do
    result = Everyday::CostPerHourCalculator.new(total_cost: -5, number_of_hours: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total cost must be greater than zero"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::CostPerHourCalculator.new(total_cost: "24", number_of_hours: "8").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3.0, result[:cost_per_hour]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::CostPerHourCalculator.new(total_cost: 24, number_of_hours: 8)
    assert_equal [], calc.errors
  end

  test "very small hourly rate" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 1, number_of_hours: 1000).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0.0, result[:cost_per_hour]  # rounds to 0.00
    assert_in_delta 0.0000, result[:cost_per_minute], 0.001
  end

  test "returns total cost and hours in result" do
    result = Everyday::CostPerHourCalculator.new(total_cost: 50, number_of_hours: 5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 50.0, result[:total_cost]
    assert_equal 5.0, result[:number_of_hours]
  end
end
