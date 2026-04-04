require "test_helper"

class Finance::CreditCardPayoffCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard credit card payoff" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: 20, monthly_payment: 200)
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert result[:months_to_payoff] > 0
    assert result[:total_interest] > 0
    assert result[:total_paid] > 5_000
    assert result[:payoff_date].present?
    assert result[:schedule].is_a?(Array)
    assert_equal result[:months_to_payoff], result[:schedule].size
  end

  test "happy path: small balance pays off quickly" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 500, apr: 18, monthly_payment: 200)
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] <= 3
    assert result[:total_interest] < 50
  end

  test "happy path: last payment is reduced to match remaining balance" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 1_000, apr: 12, monthly_payment: 500)
    result = calc.call

    assert result[:valid]
    last_entry = result[:schedule].last
    assert_in_delta 0.00, last_entry[:balance], 0.01
  end

  # --- Zero APR ---

  test "zero APR means no interest charged" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 6_000, apr: 0, monthly_payment: 1_000)
    result = calc.call

    assert result[:valid]
    assert_equal 6, result[:months_to_payoff]
    assert_in_delta 0.00, result[:total_interest], 0.01
    assert_in_delta 6_000.00, result[:total_paid], 0.01
  end

  # --- Payment too low to cover interest ---

  test "payment too low returns never-payoff error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 10_000, apr: 24, monthly_payment: 50)
    result = calc.call

    # Monthly interest on $10k at 24% = $200. $50 payment won't cover it.
    refute result[:valid]
    assert result[:errors].first.include?("does not cover")
  end

  # --- Validation: negative balance ---

  test "negative balance returns error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: -5_000, apr: 20, monthly_payment: 200)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Balance must be positive"
  end

  # --- Validation: zero balance ---

  test "zero balance returns error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 0, apr: 20, monthly_payment: 200)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Balance must be positive"
  end

  # --- Validation: negative APR ---

  test "negative APR returns error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: -5, monthly_payment: 200)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "APR cannot be negative"
  end

  # --- Validation: negative monthly payment ---

  test "negative monthly payment returns error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: 20, monthly_payment: -200)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly payment must be positive"
  end

  # --- Validation: zero monthly payment ---

  test "zero monthly payment returns error" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: 20, monthly_payment: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly payment must be positive"
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 0, apr: -5, monthly_payment: 0)
    result = calc.call

    refute result[:valid]
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: "5000", apr: "20", monthly_payment: "200")
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
  end

  # --- Large balance ---

  test "large balance still computes within safety cap" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 100_000, apr: 18, monthly_payment: 2_000)
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
    assert result[:months_to_payoff] < Finance::CreditCardPayoffCalculator::MAX_MONTHS
  end

  # --- Schedule details ---

  test "schedule entries have correct keys" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 1_000, apr: 12, monthly_payment: 200)
    result = calc.call

    assert result[:valid]
    entry = result[:schedule].first
    assert entry.key?(:month)
    assert entry.key?(:payment)
    assert entry.key?(:principal)
    assert entry.key?(:interest)
    assert entry.key?(:balance)
  end

  test "schedule months are sequential starting from 1" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 2_000, apr: 15, monthly_payment: 500)
    result = calc.call

    assert result[:valid]
    result[:schedule].each_with_index do |entry, index|
      assert_equal index + 1, entry[:month]
    end
  end

  # --- Years to payoff ---

  test "years to payoff is months divided by 12" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: 20, monthly_payment: 200)
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:months_to_payoff] / 12.0, result[:years_to_payoff], 0.1
  end

  # --- High APR edge case ---

  test "very high APR with sufficient payment still works" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 5_000, apr: 36, monthly_payment: 500)
    result = calc.call

    assert result[:valid]
    assert result[:months_to_payoff] > 0
    assert result[:total_interest] > 0
  end

  # --- Payment exactly covers balance + one month interest ---

  test "large payment pays off in one month" do
    calc = Finance::CreditCardPayoffCalculator.new(balance: 1_000, apr: 12, monthly_payment: 1_100)
    result = calc.call

    assert result[:valid]
    assert_equal 1, result[:months_to_payoff]
    # Interest for one month: 1000 * 0.12 / 12 = 10
    assert_in_delta 10.00, result[:total_interest], 0.01
  end
end
