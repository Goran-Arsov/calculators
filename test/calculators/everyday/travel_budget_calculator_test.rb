require "test_helper"

class Everyday::TravelBudgetCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "daily=150, days=7, travelers=2 → daily_total=300, trip_total=2100" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 150, num_days: 7, num_travelers: 2).call
    assert_equal true, result[:valid]
    assert_equal 300.0, result[:daily_total]
    assert_equal 2100.0, result[:trip_total]
    assert_equal 840.0, result[:accommodation]
    assert_equal 525.0, result[:food]
    assert_equal 315.0, result[:transport]
    assert_equal 420.0, result[:activities]
  end

  test "single traveler single day" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 100, num_days: 1, num_travelers: 1).call
    assert_equal true, result[:valid]
    assert_equal 100.0, result[:daily_total]
    assert_equal 100.0, result[:trip_total]
  end

  test "budget breakdown percentages sum to trip total" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 200, num_days: 5, num_travelers: 3).call
    total = result[:accommodation] + result[:food] + result[:transport] + result[:activities]
    assert_in_delta result[:trip_total], total, 0.01
  end

  test "handles string inputs" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: "100", num_days: "5", num_travelers: "2").call
    assert_equal true, result[:valid]
    assert_equal 200.0, result[:daily_total]
    assert_equal 1000.0, result[:trip_total]
  end

  # --- Validation errors ---

  test "error when daily budget is zero" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 0, num_days: 7, num_travelers: 2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Daily budget per person must be greater than zero"
  end

  test "error when num_days is zero" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 150, num_days: 0, num_travelers: 2).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of days must be at least 1"
  end

  test "error when num_travelers is zero" do
    result = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 150, num_days: 7, num_travelers: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of travelers must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TravelBudgetCalculator.new(daily_budget_per_person: 150, num_days: 7, num_travelers: 2)
    assert_equal [], calc.errors
  end
end
