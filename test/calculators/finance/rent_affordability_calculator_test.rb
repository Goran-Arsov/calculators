require "test_helper"

class Finance::RentAffordabilityCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard income with debts and savings goal" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 500, savings_goal_percent: 20
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 1_500.0, result[:max_rent_30_rule], 0.01
    # Adjusted: 5000 - 500 - (5000 * 0.20) = 5000 - 500 - 1000 = 3500
    assert_in_delta 3_500.0, result[:max_rent_adjusted], 0.01
    assert_in_delta 2_500.0, result[:needs_budget], 0.01
    assert_in_delta 1_500.0, result[:wants_budget], 0.01
    assert_in_delta 1_000.0, result[:savings_budget], 0.01
  end

  test "happy path: no debts and zero savings goal" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 4_000, monthly_debts: 0, savings_goal_percent: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_200.0, result[:max_rent_30_rule], 0.01
    # Adjusted: 4000 - 0 - 0 = 4000
    assert_in_delta 4_000.0, result[:max_rent_adjusted], 0.01
  end

  test "50/30/20 breakdown is correct" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 6_000, monthly_debts: 1_000, savings_goal_percent: 15
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 3_000.0, result[:needs_budget], 0.01
    assert_in_delta 1_800.0, result[:wants_budget], 0.01
    assert_in_delta 1_200.0, result[:savings_budget], 0.01
  end

  # --- Edge: debts exceed income ---

  test "high debts and savings produce zero adjusted rent" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 3_000, monthly_debts: 2_500, savings_goal_percent: 30
    )
    result = calc.call

    assert result[:valid]
    # Adjusted: 3000 - 2500 - 900 = -400, clamped to 0
    assert_in_delta 0.0, result[:max_rent_adjusted], 0.01
  end

  # --- Negative values ---

  test "negative monthly income returns error" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: -5_000, monthly_debts: 500, savings_goal_percent: 20
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly income must be positive"
  end

  test "negative monthly debts returns error" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: -100, savings_goal_percent: 20
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly debts cannot be negative"
  end

  test "negative savings goal percent returns error" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 500, savings_goal_percent: -10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Savings goal percent cannot be negative"
  end

  test "savings goal percent over 100 returns error" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 500, savings_goal_percent: 110
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Savings goal percent cannot exceed 100"
  end

  # --- Zero values ---

  test "zero monthly income returns error" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 0, monthly_debts: 500, savings_goal_percent: 20
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly income must be positive"
  end

  test "zero debts is valid" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 0, savings_goal_percent: 20
    )
    result = calc.call

    assert result[:valid]
  end

  test "zero savings goal is valid" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 500, savings_goal_percent: 0
    )
    result = calc.call

    assert result[:valid]
    # Adjusted: 5000 - 500 - 0 = 4500
    assert_in_delta 4_500.0, result[:max_rent_adjusted], 0.01
  end

  # --- Large numbers ---

  test "very large income computes correctly" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 100_000, monthly_debts: 5_000, savings_goal_percent: 30
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 30_000.0, result[:max_rent_30_rule], 0.01
    assert result[:max_rent_adjusted] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: -1, monthly_debts: -1, savings_goal_percent: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: "5000", monthly_debts: "500", savings_goal_percent: "20"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_500.0, result[:max_rent_30_rule], 0.01
  end

  # --- 100 percent savings goal ---

  test "100 percent savings goal means zero adjusted rent" do
    calc = Finance::RentAffordabilityCalculator.new(
      monthly_income: 5_000, monthly_debts: 0, savings_goal_percent: 100
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:max_rent_adjusted], 0.01
  end
end
