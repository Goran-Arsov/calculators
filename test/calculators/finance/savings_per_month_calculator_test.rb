require "test_helper"

class Finance::SavingsPerMonthCalculatorTest < ActiveSupport::TestCase
  # --- Happy path without interest ---

  test "basic: goal=12000, months=12, no current savings -> $1000/month" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12).call
    assert result[:valid]
    assert_equal 1_000.0, result[:monthly_savings]
    assert_equal 12_000.0, result[:remaining]
  end

  test "with current savings: goal=12000, months=12, current=3000 -> $750/month" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12, current_savings: 3000).call
    assert result[:valid]
    assert_equal 750.0, result[:monthly_savings]
    assert_equal 9_000.0, result[:remaining]
  end

  # --- With interest rate ---

  test "with interest rate reduces monthly savings needed" do
    result_no_interest = Finance::SavingsPerMonthCalculator.new(savings_goal: 10_000, months: 24).call
    result_with_interest = Finance::SavingsPerMonthCalculator.new(savings_goal: 10_000, months: 24, annual_rate: 5).call
    assert result_no_interest[:valid]
    assert result_with_interest[:valid]
    assert result_with_interest[:monthly_savings] < result_no_interest[:monthly_savings]
    assert result_with_interest[:total_interest] > 0
  end

  test "with interest and current savings" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 20_000, months: 24, current_savings: 5000, annual_rate: 6).call
    assert result[:valid]
    assert result[:monthly_savings] > 0
    assert result[:total_interest] > 0
    assert_equal 15_000.0, result[:remaining]
  end

  test "string coercion works for numeric inputs" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: "12000", months: "12").call
    assert result[:valid]
    assert_equal 1_000.0, result[:monthly_savings]
  end

  test "large goal with long timeframe" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 1_000_000, months: 360).call
    assert result[:valid]
    assert_in_delta 2_777.7778, result[:monthly_savings], 0.001
  end

  # --- Validation errors ---

  test "error when savings goal is zero" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 0, months: 12).call
    refute result[:valid]
    assert_includes result[:errors], "Savings goal must be positive"
  end

  test "error when months is zero" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Months must be positive"
  end

  test "error when current savings exceeds goal" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12, current_savings: 15_000).call
    refute result[:valid]
    assert_includes result[:errors], "Current savings cannot exceed savings goal"
  end

  test "error when current savings is negative" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12, current_savings: -500).call
    refute result[:valid]
    assert_includes result[:errors], "Current savings cannot be negative"
  end

  test "error when annual rate is negative" do
    result = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12, annual_rate: -5).call
    refute result[:valid]
    assert_includes result[:errors], "Annual interest rate cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::SavingsPerMonthCalculator.new(savings_goal: 12_000, months: 12)
    assert_equal [], calc.errors
  end
end
