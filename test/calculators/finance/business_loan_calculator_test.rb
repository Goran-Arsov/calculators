require "test_helper"

class Finance::BusinessLoanCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard business loan" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 100_000,
      annual_rate: 8.5,
      years: 5,
      origination_fee_percent: 2.0
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_equal 60, result[:num_payments]
    assert result[:monthly_payment] > 0
    assert result[:total_interest] > 0
    assert result[:total_paid] > 100_000
    assert_in_delta 2_000.00, result[:origination_fee], 0.01
    assert result[:total_cost] > result[:total_paid]
    assert result[:effective_apr] > 8.5
  end

  test "happy path: small loan with high origination fee" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 25_000,
      annual_rate: 10.0,
      years: 3,
      origination_fee_percent: 5.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_250.00, result[:origination_fee], 0.01
    # With 5% fee, effective APR should be notably higher than 10%
    assert result[:effective_apr] > 10.0
  end

  # --- Zero origination fee ---

  test "zero origination fee makes effective APR equal to nominal rate" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 50_000,
      annual_rate: 7.0,
      years: 5,
      origination_fee_percent: 0.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.00, result[:origination_fee], 0.01
    assert_in_delta result[:total_paid], result[:total_cost], 0.01
    assert_in_delta 7.0, result[:effective_apr], 0.1
  end

  # --- Zero interest rate ---

  test "zero interest rate divides amount evenly" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 24_000,
      annual_rate: 0,
      years: 2,
      origination_fee_percent: 1.0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.00, result[:monthly_payment], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
    assert_in_delta 240.00, result[:origination_fee], 0.01
  end

  # --- Validation errors ---

  test "negative amount returns error" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: -10_000,
      annual_rate: 5,
      years: 5,
      origination_fee_percent: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan amount must be positive"
  end

  test "zero amount returns error" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 0,
      annual_rate: 5,
      years: 5,
      origination_fee_percent: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan amount must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 10_000,
      annual_rate: -5,
      years: 5,
      origination_fee_percent: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "zero years returns error" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 10_000,
      annual_rate: 5,
      years: 0,
      origination_fee_percent: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  test "negative origination fee returns error" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 10_000,
      annual_rate: 5,
      years: 5,
      origination_fee_percent: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Origination fee cannot be negative"
  end

  test "multiple validation errors returned at once" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 0,
      annual_rate: -1,
      years: 0,
      origination_fee_percent: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: "100000",
      annual_rate: "8.5",
      years: "5",
      origination_fee_percent: "2.0"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  # --- Large numbers ---

  test "very large loan amount still computes" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 10_000_000,
      annual_rate: 6.0,
      years: 10,
      origination_fee_percent: 1.0
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_in_delta 100_000.00, result[:origination_fee], 0.01
    assert result[:total_cost] > result[:total_paid]
  end

  # --- Edge case: 1-year loan ---

  test "one year loan at high interest" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 50_000,
      annual_rate: 20,
      years: 1,
      origination_fee_percent: 3.0
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:num_payments]
    assert result[:monthly_payment] > 50_000 / 12.0
    assert result[:total_interest] > 0
    assert_in_delta 1_500.00, result[:origination_fee], 0.01
  end

  # --- Total cost includes origination fee ---

  test "total cost equals total paid plus origination fee" do
    calc = Finance::BusinessLoanCalculator.new(
      amount: 75_000,
      annual_rate: 9.0,
      years: 7,
      origination_fee_percent: 2.5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:total_paid] + result[:origination_fee], result[:total_cost], 0.01
  end
end
