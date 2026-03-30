require "test_helper"

class Finance::RetirementCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: 30 to 65 with savings and contributions at 7%" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: 50_000,
      monthly_contribution: 1_000, annual_rate: 7
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_equal 35, result[:years_to_retire]

    # Total contributions = 50000 + 1000 * 420 = 470000
    assert_in_delta 470_000.00, result[:total_contributions], 0.01

    # Projected savings should be much larger than contributions
    assert result[:projected_savings] > 470_000

    # Monthly retirement income = projected_savings * 0.04 / 12
    expected_income = result[:projected_savings] * 0.04 / 12.0
    assert_in_delta expected_income, result[:monthly_retirement_income], 0.01
  end

  test "happy path: already near retirement" do
    calc = Finance::RetirementCalculator.new(
      current_age: 60, retirement_age: 65, current_savings: 500_000,
      monthly_contribution: 2_000, annual_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5, result[:years_to_retire]
    assert result[:projected_savings] > 500_000
  end

  # --- Zero interest rate ---

  test "zero interest rate: projected savings equals total contributions" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: 10_000,
      monthly_contribution: 500, annual_rate: 0
    )
    result = calc.call

    assert result[:valid]
    expected = 10_000 + 500.0 * 420
    assert_in_delta expected, result[:projected_savings], 0.01
    assert_in_delta expected, result[:total_contributions], 0.01
  end

  # --- Negative values ---

  test "negative current age returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: -5, retirement_age: 65, current_savings: 10_000,
      monthly_contribution: 500, annual_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current age must be positive"
  end

  test "retirement age less than current age returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 50, retirement_age: 40, current_savings: 10_000,
      monthly_contribution: 500, annual_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Retirement age must be greater than current age"
  end

  test "negative current savings returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: -10_000,
      monthly_contribution: 500, annual_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current savings cannot be negative"
  end

  test "negative monthly contribution returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: 10_000,
      monthly_contribution: -500, annual_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly contribution cannot be negative"
  end

  test "negative interest rate returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: 10_000,
      monthly_contribution: 500, annual_rate: -3
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  # --- Zero values ---

  test "zero current age returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 0, retirement_age: 65, current_savings: 10_000,
      monthly_contribution: 500, annual_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current age must be positive"
  end

  test "retirement age equal to current age returns error" do
    calc = Finance::RetirementCalculator.new(
      current_age: 65, retirement_age: 65, current_savings: 100_000,
      monthly_contribution: 0, annual_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Retirement age must be greater than current age"
  end

  test "zero savings and zero contribution still valid if ages are valid" do
    calc = Finance::RetirementCalculator.new(
      current_age: 25, retirement_age: 65, current_savings: 0,
      monthly_contribution: 0, annual_rate: 7
    )
    result = calc.call

    # Both savings and contribution are zero but no validation error for that
    assert result[:valid]
    assert_in_delta 0.0, result[:projected_savings], 0.01
    assert_in_delta 0.0, result[:monthly_retirement_income], 0.01
  end

  # --- Large numbers ---

  test "very large current savings still computes" do
    calc = Finance::RetirementCalculator.new(
      current_age: 25, retirement_age: 70, current_savings: 10_000_000,
      monthly_contribution: 10_000, annual_rate: 10
    )
    result = calc.call

    assert result[:valid]
    assert result[:projected_savings] > 10_000_000
    assert result[:monthly_retirement_income] > 0
  end

  test "very large age gap still computes" do
    calc = Finance::RetirementCalculator.new(
      current_age: 18, retirement_age: 100, current_savings: 1_000,
      monthly_contribution: 100, annual_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 82, result[:years_to_retire]
    assert result[:projected_savings] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::RetirementCalculator.new(
      current_age: -1, retirement_age: -5, current_savings: -1,
      monthly_contribution: -1, annual_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::RetirementCalculator.new(
      current_age: "30", retirement_age: "65", current_savings: "50000",
      monthly_contribution: "1000", annual_rate: "7"
    )
    result = calc.call

    assert result[:valid]
    assert result[:projected_savings] > 0
  end

  # --- Edge case: retire in 1 year ---

  test "one year to retirement" do
    calc = Finance::RetirementCalculator.new(
      current_age: 64, retirement_age: 65, current_savings: 1_000_000,
      monthly_contribution: 5_000, annual_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 1, result[:years_to_retire]
    assert result[:projected_savings] > 1_000_000
  end

  # --- 4% rule verification ---

  test "monthly retirement income follows 4 percent rule" do
    calc = Finance::RetirementCalculator.new(
      current_age: 30, retirement_age: 65, current_savings: 100_000,
      monthly_contribution: 0, annual_rate: 0
    )
    result = calc.call

    assert result[:valid]
    # With 0% growth, projected savings = 100000
    expected_monthly_income = 100_000 * 0.04 / 12.0
    assert_in_delta expected_monthly_income, result[:monthly_retirement_income], 0.01
  end
end
