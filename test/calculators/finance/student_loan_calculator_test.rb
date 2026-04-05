require "test_helper"

class Finance::StudentLoanCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: Standard ---

  test "happy path: standard 10-year repayment" do
    calc = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: 5.5, loan_term_years: 10)
    result = calc.call

    assert result[:valid]
    assert_in_delta 379.61, result[:monthly_payment], 1.0
    assert_equal 120, result[:num_payments]
    assert result[:total_paid] > 35_000
    assert result[:total_interest] > 0
    assert_equal "standard", result[:plan_type]
  end

  test "happy path: standard with zero interest" do
    calc = Finance::StudentLoanCalculator.new(balance: 12_000, annual_rate: 0, loan_term_years: 10)
    result = calc.call

    assert result[:valid]
    assert_in_delta 100.0, result[:monthly_payment], 0.01
    assert_in_delta 0.0, result[:total_interest], 0.01
  end

  # --- Graduated plan ---

  test "graduated plan starts lower than standard" do
    standard = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: 5.5, loan_term_years: 10, plan_type: "standard")
    graduated = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: 5.5, loan_term_years: 10, plan_type: "graduated")

    std_result = standard.call
    grad_result = graduated.call

    assert std_result[:valid]
    assert grad_result[:valid]
    # Graduated starts at 60% of standard
    assert grad_result[:monthly_payment] < std_result[:monthly_payment]
  end

  # --- Extended plan ---

  test "extended plan has lower monthly payment but more total interest" do
    standard = Finance::StudentLoanCalculator.new(balance: 50_000, annual_rate: 6, loan_term_years: 10, plan_type: "standard")
    extended = Finance::StudentLoanCalculator.new(balance: 50_000, annual_rate: 6, plan_type: "extended")

    std_result = standard.call
    ext_result = extended.call

    assert std_result[:valid]
    assert ext_result[:valid]
    assert ext_result[:monthly_payment] < std_result[:monthly_payment]
    assert ext_result[:total_interest] > std_result[:total_interest]
    assert_equal 300, ext_result[:num_payments]
  end

  # --- Income-driven plan ---

  test "income-driven plan uses 10% of discretionary income" do
    calc = Finance::StudentLoanCalculator.new(
      balance: 50_000, annual_rate: 6, plan_type: "income_driven",
      monthly_income: 4_000
    )
    result = calc.call

    assert result[:valid]
    # Discretionary: (4000*12 - 22590*1.5) * 0.10 / 12
    annual_income = 4_000 * 12
    discretionary = annual_income - 22_590 * 1.5
    expected_payment = discretionary * 0.10 / 12.0
    assert_in_delta expected_payment, result[:monthly_payment], 1.0
  end

  test "income-driven plan without income returns error" do
    calc = Finance::StudentLoanCalculator.new(
      balance: 50_000, annual_rate: 6, plan_type: "income_driven",
      monthly_income: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly income required for income-driven plan"
  end

  # --- Zero / Negative values ---

  test "zero balance returns error" do
    calc = Finance::StudentLoanCalculator.new(balance: 0, annual_rate: 5, loan_term_years: 10)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan balance must be positive"
  end

  test "negative balance returns error" do
    calc = Finance::StudentLoanCalculator.new(balance: -10_000, annual_rate: 5, loan_term_years: 10)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan balance must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: -2, loan_term_years: 10)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "zero term returns error" do
    calc = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: 5, loan_term_years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  test "invalid plan type returns error" do
    calc = Finance::StudentLoanCalculator.new(balance: 35_000, annual_rate: 5, plan_type: "avalanche")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid plan type"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::StudentLoanCalculator.new(balance: "35000", annual_rate: "5.5", loan_term_years: "10")
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  # --- Large numbers ---

  test "very large balance still computes" do
    calc = Finance::StudentLoanCalculator.new(balance: 500_000, annual_rate: 7, loan_term_years: 10)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:total_interest] > 0
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::StudentLoanCalculator.new(
      balance: -1, annual_rate: -1, loan_term_years: 0, plan_type: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end
end
