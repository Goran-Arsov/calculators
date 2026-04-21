require "test_helper"

class Finance::SavingsGoalCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: save 50k in 5 years at 5% with no current savings" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 50_000, years: 5, annual_rate: 5, current_savings: 0
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 50_000.00, result[:goal], 0.01

    # monthly_savings should be less than 50000/60 since interest helps
    assert result[:monthly_savings] > 0
    assert result[:monthly_savings] < 50_000.0 / 60

    # Verify the math: monthly_rate = 0.05/12, n = 60
    # monthly_savings = 50000 * (0.05/12) / ((1 + 0.05/12)^60 - 1)
    monthly_rate = 0.05 / 12.0
    expected_monthly = 50_000 * monthly_rate / ((1 + monthly_rate)**60 - 1)
    assert_in_delta expected_monthly, result[:monthly_savings], 0.01

    assert result[:total_interest] > 0
  end

  test "happy path: save 100k in 10 years at 6% with 20k current savings" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 100_000, years: 10, annual_rate: 6, current_savings: 20_000
    )
    result = calc.call

    assert result[:valid]
    # Current savings grow, so less monthly savings needed
    assert result[:monthly_savings] > 0
    assert result[:total_interest] > 0
  end

  # --- Zero interest rate ---

  test "zero interest rate: monthly savings is simple division" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 12_000, years: 1, annual_rate: 0, current_savings: 0
    )
    result = calc.call

    assert result[:valid]
    # 12000 / 12 = 1000
    assert_in_delta 1_000.00, result[:monthly_savings], 0.01
    assert_in_delta 0.0, result[:total_interest], 0.01
  end

  test "zero interest rate with existing savings" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 12_000, years: 1, annual_rate: 0, current_savings: 6_000
    )
    result = calc.call

    assert result[:valid]
    # (12000 - 6000) / 12 = 500
    assert_in_delta 500.00, result[:monthly_savings], 0.01
  end

  # --- Current savings already exceed goal ---

  test "current savings already exceed goal with interest: monthly savings is zero" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 5, annual_rate: 10, current_savings: 20_000
    )
    result = calc.call

    assert result[:valid]
    # Current savings with growth far exceed goal, so monthly_savings should be 0 (clamped)
    assert_in_delta 0.0, result[:monthly_savings], 0.01
  end

  # --- Negative values ---

  test "negative goal returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: -10_000, years: 5, annual_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Goal amount must be positive"
  end

  test "negative years returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: -5, annual_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 5, annual_rate: -3
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative current savings returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 5, annual_rate: 5, current_savings: -1_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current savings cannot be negative"
  end

  # --- Zero values ---

  test "zero goal returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 0, years: 5, annual_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Goal amount must be positive"
  end

  test "zero years returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 0, annual_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  # --- Large numbers ---

  test "very large goal still computes" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000_000, years: 30, annual_rate: 7, current_savings: 0
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_savings] > 0
    assert result[:total_interest] > 0
  end

  test "very large current savings still computes" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 100_000_000, years: 20, annual_rate: 5, current_savings: 50_000_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_savings] >= 0
  end

  test "very long time period still computes" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 1_000_000, years: 100, annual_rate: 3, current_savings: 0
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_savings] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: -1, years: 0, annual_rate: -1, current_savings: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Goal amount must be positive"
    assert_includes calc.errors, "Time period must be positive"
    assert_includes calc.errors, "Interest rate cannot be negative"
    assert_includes calc.errors, "Current savings cannot be negative"
    assert_equal 4, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: "50000", years: "5", annual_rate: "5", current_savings: "0"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_savings] > 0
  end

  # --- Edge case: default current_savings ---

  test "current savings defaults to zero" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 2, annual_rate: 4
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_savings] > 0
  end

  # --- Edge case: 1 year savings plan ---

  test "one year savings goal" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 6_000, years: 1, annual_rate: 6, current_savings: 0
    )
    result = calc.call

    assert result[:valid]
    # With interest, monthly contribution should be less than 500
    assert result[:monthly_savings] < 500
    assert result[:monthly_savings] > 0
  end

  # --- Edge case: goal equals current savings (with interest) ---

  test "goal matches current savings exactly at zero rate" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 10_000, years: 5, annual_rate: 0, current_savings: 10_000
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:monthly_savings], 0.01
  end

  # --- Inflation adjustment (optional) ---

  test "inflation: absent kwarg returns no real_* keys" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 50_000, years: 10, annual_rate: 5
    )
    result = calc.call

    assert result[:valid]
    refute result.key?(:real_goal)
    refute result.key?(:real_total_interest)
    refute result.key?(:annual_inflation_rate)
  end

  test "inflation: zero rate makes real values equal nominal" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 50_000, years: 10, annual_rate: 5, annual_inflation_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:goal], result[:real_goal], 0.01
    assert_in_delta result[:total_interest], result[:real_total_interest], 0.01
  end

  test "inflation: 3% over 10 years reduces real values by compounded factor" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 50_000, years: 10, annual_rate: 5, annual_inflation_rate: 3
    )
    result = calc.call

    assert result[:valid]
    factor = 1.03**10
    assert_operator result[:real_goal], :<, result[:goal]
    assert_in_delta result[:goal] / factor, result[:real_goal], 0.01
    assert_in_delta result[:total_interest] / factor, result[:real_total_interest], 0.01
  end

  test "inflation: negative rate returns error" do
    calc = Finance::SavingsGoalCalculator.new(
      goal: 50_000, years: 10, annual_rate: 5, annual_inflation_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Inflation rate cannot be negative"
  end
end
