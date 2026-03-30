require "test_helper"

class Finance::MortgageCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard 30-year mortgage at 6%" do
    calc = Finance::MortgageCalculator.new(principal: 300_000, annual_rate: 6, years: 30)
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 1798.65, result[:monthly_payment], 0.01
    assert_equal 360, result[:num_payments]
    assert_in_delta 647_514.57, result[:total_paid], 1.0
    assert_in_delta 347_514.57, result[:total_interest], 1.0
  end

  test "happy path: 15-year mortgage at 5%" do
    calc = Finance::MortgageCalculator.new(principal: 200_000, annual_rate: 5, years: 15)
    result = calc.call

    assert result[:valid]
    assert_equal 180, result[:num_payments]
    assert_in_delta 1581.59, result[:monthly_payment], 0.01
  end

  test "happy path: short term 1-year mortgage" do
    calc = Finance::MortgageCalculator.new(principal: 12_000, annual_rate: 12, years: 1)
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:num_payments]
    assert_in_delta 1066.19, result[:monthly_payment], 0.01
  end

  # --- Zero interest rate ---

  test "zero interest rate divides principal evenly" do
    calc = Finance::MortgageCalculator.new(principal: 120_000, annual_rate: 0, years: 10)
    result = calc.call

    assert result[:valid]
    assert_in_delta 1000.00, result[:monthly_payment], 0.01
    assert_in_delta 120_000.00, result[:total_paid], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
    assert_equal 120, result[:num_payments]
  end

  # --- Negative values ---

  test "negative principal returns error" do
    calc = Finance::MortgageCalculator.new(principal: -100_000, annual_rate: 5, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::MortgageCalculator.new(principal: 100_000, annual_rate: -3, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative years returns error" do
    calc = Finance::MortgageCalculator.new(principal: 100_000, annual_rate: 5, years: -5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  # --- Zero values ---

  test "zero principal returns error" do
    calc = Finance::MortgageCalculator.new(principal: 0, annual_rate: 5, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "zero years returns error" do
    calc = Finance::MortgageCalculator.new(principal: 100_000, annual_rate: 5, years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  # --- Large numbers ---

  test "very large principal still computes" do
    calc = Finance::MortgageCalculator.new(principal: 100_000_000, annual_rate: 3.5, years: 30)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:total_paid] > result[:monthly_payment]
    assert result[:total_interest] > 0
  end

  test "very large years still computes" do
    calc = Finance::MortgageCalculator.new(principal: 200_000, annual_rate: 4, years: 100)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_equal 1200, result[:num_payments]
  end

  # --- Validation errors: multiple at once ---

  test "multiple validation errors returned at once" do
    calc = Finance::MortgageCalculator.new(principal: -1, annual_rate: -1, years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
    assert_includes calc.errors, "Loan term must be positive"
    assert_includes calc.errors, "Interest rate cannot be negative"
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::MortgageCalculator.new(principal: "250000", annual_rate: "4.5", years: "30")
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  # --- Edge cases ---

  test "very small interest rate still works" do
    calc = Finance::MortgageCalculator.new(principal: 100_000, annual_rate: 0.01, years: 30)
    result = calc.call

    assert result[:valid]
    # With near-zero rate, monthly payment should be close to principal / num_payments
    assert_in_delta(100_000.0 / 360, result[:monthly_payment], 5.0)
  end

  test "one year term at high interest" do
    calc = Finance::MortgageCalculator.new(principal: 10_000, annual_rate: 24, years: 1)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 10_000 / 12.0
    assert result[:total_interest] > 0
  end
end
