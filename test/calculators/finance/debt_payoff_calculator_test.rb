require "test_helper"

class Finance::DebtPayoffCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: credit card debt payoff" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 5_000, annual_rate: 18, monthly_payment: 200
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors

    # Math.log(1 - 0.015 * 5000 / 200) / Math.log(1.015) => ~31 months
    assert_in_delta 31, result[:months_to_payoff], 1
    assert_in_delta 31 / 12.0, result[:years_to_payoff], 0.2
    assert result[:total_paid] > 5_000
    assert result[:total_interest] > 0
    assert_in_delta result[:total_paid] - 5_000, result[:total_interest], 0.01
  end

  test "happy path: large balance with moderate payments" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 20_000, annual_rate: 12, monthly_payment: 500
    )
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
    assert result[:total_interest] > 0
  end

  # --- Zero interest rate ---

  test "zero interest rate: months equals balance divided by payment, rounded up" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 10_000, annual_rate: 0, monthly_payment: 300
    )
    result = calc.call

    assert result[:valid]
    # 10000 / 300 = 33.33, ceil = 34
    assert_equal 34, result[:months_to_payoff]
    assert_in_delta 2.8, result[:years_to_payoff], 0.1
    assert_in_delta 300 * 34, result[:total_paid], 0.01
    # Some overpayment since ceil rounds up, but balance is fully covered
    assert result[:total_interest] >= 0
  end

  test "zero interest rate: exact division" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 6_000, annual_rate: 0, monthly_payment: 500
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:months_to_payoff]
    assert_in_delta 6_000.00, result[:total_paid], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
  end

  # --- Negative values ---

  test "negative balance returns error" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: -5_000, annual_rate: 18, monthly_payment: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Balance must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 5_000, annual_rate: -5, monthly_payment: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative monthly payment returns error" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 5_000, annual_rate: 18, monthly_payment: -200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly payment must be positive"
  end

  # --- Zero values ---

  test "zero balance returns error" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 0, annual_rate: 18, monthly_payment: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Balance must be positive"
  end

  test "zero monthly payment returns error" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 5_000, annual_rate: 18, monthly_payment: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly payment must be positive"
  end

  # --- Payment too low (does not exceed interest) ---

  test "payment less than monthly interest returns specific error" do
    # Monthly interest = 10000 * (0.24/12) = 200
    calc = Finance::DebtPayoffCalculator.new(
      balance: 10_000, annual_rate: 24, monthly_payment: 150
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("Monthly payment must exceed minimum interest charge") }
  end

  test "payment exactly equal to monthly interest returns specific error" do
    # Monthly interest = 10000 * (0.24/12) = 200
    calc = Finance::DebtPayoffCalculator.new(
      balance: 10_000, annual_rate: 24, monthly_payment: 200
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.any? { |e| e.include?("Monthly payment must exceed minimum interest charge") }
  end

  # --- Large numbers ---

  test "very large balance still computes" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 1_000_000, annual_rate: 6, monthly_payment: 10_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
    assert result[:total_paid] > 1_000_000
  end

  test "very large monthly payment pays off quickly" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 1_000, annual_rate: 12, monthly_payment: 10_000
    )
    result = calc.call

    assert result[:valid]
    assert_equal 1, result[:months_to_payoff]
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 0, annual_rate: -1, monthly_payment: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Balance must be positive"
    assert_includes calc.errors, "Monthly payment must be positive"
    assert_includes calc.errors, "Interest rate cannot be negative"
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: "5000", annual_rate: "18", monthly_payment: "200"
    )
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
  end

  # --- Edge case: payment barely exceeds interest ---

  test "payment just barely exceeds monthly interest takes a long time" do
    # Monthly interest = 10000 * (0.12/12) = 100
    calc = Finance::DebtPayoffCalculator.new(
      balance: 10_000, annual_rate: 12, monthly_payment: 101
    )
    result = calc.call

    assert result[:valid]
    # Should take a very long time
    assert result[:months_to_payoff] > 100
  end

  # --- Edge case: years_to_payoff formatting ---

  test "years to payoff is correctly calculated from months" do
    calc = Finance::DebtPayoffCalculator.new(
      balance: 1_200, annual_rate: 0, monthly_payment: 100
    )
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:months_to_payoff]
    assert_in_delta 1.0, result[:years_to_payoff], 0.01
  end
end
