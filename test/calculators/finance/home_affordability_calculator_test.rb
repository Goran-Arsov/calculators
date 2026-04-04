require "test_helper"

class Finance::HomeAffordabilityCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: typical home buyer" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: 500,
      down_payment: 60_000,
      interest_rate: 6.75,
      loan_term: 30,
      property_tax_rate: 1.25,
      annual_insurance: 1_800
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert result[:max_home_price] > 0
    assert result[:max_loan_amount] > 0
    assert result[:monthly_pi] > 0
    assert result[:monthly_tax] > 0
    assert result[:monthly_insurance] > 0
    assert result[:total_monthly_payment] > 0
    assert result[:front_end_dti] <= 28.0
    assert result[:back_end_dti] <= 36.0
    # Down payment should be included in max home price
    assert result[:max_home_price] > result[:max_loan_amount]
    assert_in_delta 60_000.00, result[:down_payment], 0.01
  end

  test "happy path: high income low debt" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 200_000,
      monthly_debts: 0,
      down_payment: 100_000,
      interest_rate: 6.0,
      loan_term: 30,
      property_tax_rate: 1.0,
      annual_insurance: 2_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:max_home_price] > 500_000
  end

  # --- Back-end DTI limiting ---

  test "high existing debt limits affordability via back-end DTI" do
    # With $2,500 in monthly debts, the back-end DTI (36%) will be more limiting
    calc_low_debt = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: 0,
      down_payment: 60_000,
      interest_rate: 6.75,
      loan_term: 30,
      property_tax_rate: 1.25,
      annual_insurance: 1_800
    )
    calc_high_debt = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: 2_000,
      down_payment: 60_000,
      interest_rate: 6.75,
      loan_term: 30,
      property_tax_rate: 1.25,
      annual_insurance: 1_800
    )

    low_debt_result = calc_low_debt.call
    high_debt_result = calc_high_debt.call

    assert low_debt_result[:valid]
    assert high_debt_result[:valid]
    assert high_debt_result[:max_home_price] < low_debt_result[:max_home_price]
  end

  # --- Zero interest rate ---

  test "zero interest rate still computes" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 100_000,
      monthly_debts: 0,
      down_payment: 50_000,
      interest_rate: 0,
      loan_term: 30,
      property_tax_rate: 1.0,
      annual_insurance: 1_200
    )
    result = calc.call

    assert result[:valid]
    assert result[:max_home_price] > 0
  end

  # --- Validation errors ---

  test "negative income returns error" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: -50_000,
      monthly_debts: 0,
      down_payment: 0,
      interest_rate: 6,
      loan_term: 30,
      property_tax_rate: 1,
      annual_insurance: 1200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual income must be positive"
  end

  test "zero income returns error" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 0,
      monthly_debts: 0,
      down_payment: 0,
      interest_rate: 6,
      loan_term: 30,
      property_tax_rate: 1,
      annual_insurance: 1200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual income must be positive"
  end

  test "negative monthly debts returns error" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: -500,
      down_payment: 0,
      interest_rate: 6,
      loan_term: 30,
      property_tax_rate: 1,
      annual_insurance: 1200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly debts cannot be negative"
  end

  test "zero loan term returns error" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: 0,
      down_payment: 0,
      interest_rate: 6,
      loan_term: 0,
      property_tax_rate: 1,
      annual_insurance: 1200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 85_000,
      monthly_debts: 0,
      down_payment: 0,
      interest_rate: -3,
      loan_term: 30,
      property_tax_rate: 1,
      annual_insurance: 1200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "multiple validation errors returned at once" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 0,
      monthly_debts: -1,
      down_payment: -1,
      interest_rate: -1,
      loan_term: 0,
      property_tax_rate: -1,
      annual_insurance: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 5
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: "85000",
      monthly_debts: "500",
      down_payment: "60000",
      interest_rate: "6.75",
      loan_term: "30",
      property_tax_rate: "1.25",
      annual_insurance: "1800"
    )
    result = calc.call

    assert result[:valid]
    assert result[:max_home_price] > 0
  end

  # --- Large numbers ---

  test "very high income still computes" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 5_000_000,
      monthly_debts: 0,
      down_payment: 1_000_000,
      interest_rate: 5.0,
      loan_term: 30,
      property_tax_rate: 1.0,
      annual_insurance: 5_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:max_home_price] > 1_000_000
  end

  # --- Monthly breakdown adds up ---

  test "monthly breakdown components sum to total" do
    calc = Finance::HomeAffordabilityCalculator.new(
      annual_income: 100_000,
      monthly_debts: 300,
      down_payment: 50_000,
      interest_rate: 7.0,
      loan_term: 30,
      property_tax_rate: 1.5,
      annual_insurance: 2_400
    )
    result = calc.call

    assert result[:valid]
    expected_total = result[:monthly_pi] + result[:monthly_tax] + result[:monthly_insurance]
    assert_in_delta expected_total, result[:total_monthly_payment], 0.02
  end
end
