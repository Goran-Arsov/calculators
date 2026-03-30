require "test_helper"

class Finance::LoanCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard 5-year auto loan at 7%" do
    calc = Finance::LoanCalculator.new(amount: 25_000, annual_rate: 7, years: 5)
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_equal 60, result[:num_payments]
    # Monthly payment for 25k at 7% for 5 years ~ 495.03
    assert_in_delta 495.03, result[:monthly_payment], 0.01
    total_paid = 495.03 * 60
    assert_in_delta total_paid, result[:total_paid], 1.0
    assert_in_delta total_paid - 25_000, result[:total_interest], 1.0
  end

  test "happy path: 3-year personal loan at 10%" do
    calc = Finance::LoanCalculator.new(amount: 10_000, annual_rate: 10, years: 3)
    result = calc.call

    assert result[:valid]
    assert_equal 36, result[:num_payments]
    assert_in_delta 322.67, result[:monthly_payment], 0.01
  end

  # --- Zero interest rate ---

  test "zero interest rate divides amount evenly" do
    calc = Finance::LoanCalculator.new(amount: 24_000, annual_rate: 0, years: 2)
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.00, result[:monthly_payment], 0.01
    assert_in_delta 24_000.00, result[:total_paid], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
  end

  # --- Negative values ---

  test "negative amount returns error" do
    calc = Finance::LoanCalculator.new(amount: -10_000, annual_rate: 5, years: 5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan amount must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::LoanCalculator.new(amount: 10_000, annual_rate: -5, years: 5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative years returns error" do
    calc = Finance::LoanCalculator.new(amount: 10_000, annual_rate: 5, years: -5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  # --- Zero values ---

  test "zero amount returns error" do
    calc = Finance::LoanCalculator.new(amount: 0, annual_rate: 5, years: 5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan amount must be positive"
  end

  test "zero years returns error" do
    calc = Finance::LoanCalculator.new(amount: 10_000, annual_rate: 5, years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  # --- Large numbers ---

  test "very large loan amount still computes" do
    calc = Finance::LoanCalculator.new(amount: 500_000_000, annual_rate: 4.5, years: 30)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:total_paid] > 500_000_000
    assert result[:total_interest] > 0
  end

  test "very long loan term still computes" do
    calc = Finance::LoanCalculator.new(amount: 100_000, annual_rate: 3, years: 50)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_equal 600, result[:num_payments]
  end

  # --- Validation errors: multiple at once ---

  test "multiple validation errors returned at once" do
    calc = Finance::LoanCalculator.new(amount: 0, annual_rate: -1, years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan amount must be positive"
    assert_includes calc.errors, "Loan term must be positive"
    assert_includes calc.errors, "Interest rate cannot be negative"
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::LoanCalculator.new(amount: "25000", annual_rate: "7", years: "5")
    result = calc.call

    assert result[:valid]
    assert_in_delta 495.03, result[:monthly_payment], 0.01
  end

  # --- Edge case: 1-year loan ---

  test "one year loan at high interest" do
    calc = Finance::LoanCalculator.new(amount: 5_000, annual_rate: 20, years: 1)
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:num_payments]
    assert result[:monthly_payment] > 5_000 / 12.0
    assert result[:total_interest] > 0
  end
end
