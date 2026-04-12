require "test_helper"

class Relationships::DateNightBudgetCalculatorTest < ActiveSupport::TestCase
  test "default values calculate correctly" do
    result = Relationships::DateNightBudgetCalculator.new(
      dinner: 60, activity: 30, transport: 15, extras: 20, dates_per_month: 4
    ).call
    assert result[:valid]
    assert_in_delta 125, result[:per_date], 0.01
    assert_in_delta 500, result[:monthly], 0.01
    assert_in_delta 6000, result[:annual], 0.01
  end

  test "negative cost errors" do
    result = Relationships::DateNightBudgetCalculator.new(
      dinner: -5, activity: 30, transport: 15, extras: 20, dates_per_month: 4
    ).call
    assert_equal false, result[:valid]
  end

  test "zero dates per month errors" do
    result = Relationships::DateNightBudgetCalculator.new(
      dinner: 60, activity: 30, transport: 15, extras: 20, dates_per_month: 0
    ).call
    assert_equal false, result[:valid]
  end
end
