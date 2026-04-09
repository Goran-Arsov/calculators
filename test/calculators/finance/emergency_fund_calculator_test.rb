require "test_helper"

class Finance::EmergencyFundCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: moderate risk with gap" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "moderate", current_savings: 5_000, monthly_contribution: 500
    )
    result = calc.call

    assert result[:valid]
    assert_equal 6, result[:months_recommended]
    assert_in_delta 18_000.0, result[:target_fund], 0.01
    assert_in_delta 13_000.0, result[:savings_gap], 0.01
    # 13000 / 500 = 26 months
    assert_equal 26, result[:months_to_goal]
    # 5000 / 18000 * 100 = 27.8%
    assert_in_delta 27.8, result[:percent_funded], 0.1
  end

  test "happy path: stable risk requires 3 months" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 4_000, risk_level: "stable", current_savings: 0, monthly_contribution: 1_000
    )
    result = calc.call

    assert result[:valid]
    assert_equal 3, result[:months_recommended]
    assert_in_delta 12_000.0, result[:target_fund], 0.01
    assert_in_delta 12_000.0, result[:savings_gap], 0.01
    assert_equal 12, result[:months_to_goal]
  end

  test "happy path: high risk requires 9 months" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 2_000, risk_level: "high_risk", current_savings: 10_000, monthly_contribution: 500
    )
    result = calc.call

    assert result[:valid]
    assert_equal 9, result[:months_recommended]
    assert_in_delta 18_000.0, result[:target_fund], 0.01
    assert_in_delta 8_000.0, result[:savings_gap], 0.01
    assert_equal 16, result[:months_to_goal]
  end

  test "happy path: already fully funded" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "moderate", current_savings: 20_000, monthly_contribution: 500
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:savings_gap], 0.01
    assert_equal 0, result[:months_to_goal]
    assert_in_delta 100.0, result[:percent_funded], 0.1
  end

  test "happy path: overfunded caps percent at 100" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 2_000, risk_level: "stable", current_savings: 50_000, monthly_contribution: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 100.0, result[:percent_funded], 0.1
    assert_in_delta 0.0, result[:savings_gap], 0.01
  end

  test "happy path: zero contribution with gap returns nil months_to_goal" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "moderate", current_savings: 1_000, monthly_contribution: 0
    )
    result = calc.call

    assert result[:valid]
    assert_nil result[:months_to_goal]
    assert result[:savings_gap] > 0
  end

  # --- Validation errors ---

  test "zero monthly expenses returns error" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 0, risk_level: "moderate", current_savings: 0, monthly_contribution: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly expenses must be positive"
  end

  test "negative monthly expenses returns error" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: -1, risk_level: "moderate", current_savings: 0, monthly_contribution: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly expenses must be positive"
  end

  test "invalid risk level returns error" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "extreme", current_savings: 0, monthly_contribution: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid risk level"
  end

  test "negative current savings returns error" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "moderate", current_savings: -1, monthly_contribution: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current savings cannot be negative"
  end

  test "negative monthly contribution returns error" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 3_000, risk_level: "moderate", current_savings: 0, monthly_contribution: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly contribution cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: "3000", risk_level: "moderate", current_savings: "5000", monthly_contribution: "500"
    )
    result = calc.call

    assert result[:valid]
    assert result[:target_fund] > 0
  end

  # --- Large numbers ---

  test "very large expenses still computes" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: 100_000, risk_level: "high_risk", current_savings: 0, monthly_contribution: 10_000
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 900_000.0, result[:target_fund], 0.01
    assert_equal 90, result[:months_to_goal]
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::EmergencyFundCalculator.new(
      monthly_expenses: -1, risk_level: "bogus", current_savings: -1, monthly_contribution: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end
end
