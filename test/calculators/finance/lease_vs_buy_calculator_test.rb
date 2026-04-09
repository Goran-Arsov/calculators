require "test_helper"

class Finance::LeaseVsBuyCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: buy is cheaper than lease" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 35_000, down_payment_buy: 5_000, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 450, lease_term_months: 36,
      lease_down_payment: 2_000, estimated_resale_value: 20_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:buy_monthly_payment] > 0
    assert result[:total_buy_cost] > 0
    assert result[:total_buy_net] > 0
    assert result[:total_lease_cost] > 0
    assert result[:savings_amount] > 0
    assert_includes %w[buy lease], result[:recommendation]
  end

  test "happy path: lease is cheaper" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 50_000, down_payment_buy: 5_000, loan_rate_percent: 7,
      loan_term_months: 72, lease_monthly_payment: 400, lease_term_months: 36,
      lease_down_payment: 1_000, estimated_resale_value: 15_000
    )
    result = calc.call

    assert result[:valid]
    total_lease = 1_000 + (400 * 36)
    assert_in_delta total_lease, result[:total_lease_cost], 0.01
  end

  test "happy path: zero interest rate" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 5_000, loan_rate_percent: 0,
      loan_term_months: 60, lease_monthly_payment: 350, lease_term_months: 36,
      lease_down_payment: 1_500, estimated_resale_value: 15_000
    )
    result = calc.call

    assert result[:valid]
    # Monthly payment = 25000 / 60 = 416.67
    assert_in_delta 416.67, result[:buy_monthly_payment], 0.01
    # Total buy = 5000 + 416.67 * 60 = 30000
    assert_in_delta 30_000.0, result[:total_buy_cost], 0.01
    # Net buy = 30000 - 15000 = 15000
    assert_in_delta 15_000.0, result[:total_buy_net], 0.01
  end

  test "happy path: resale value exceeds total buy cost" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 20_000, down_payment_buy: 5_000, loan_rate_percent: 3,
      loan_term_months: 36, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 1_000, estimated_resale_value: 25_000
    )
    result = calc.call

    assert result[:valid]
    # Net buy should be negative (profit)
    assert result[:total_buy_net] < 0
    assert_equal "buy", result[:recommendation]
  end

  test "happy path: lease total calculation" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 3_000, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 350, lease_term_months: 36,
      lease_down_payment: 2_000, estimated_resale_value: 12_000
    )
    result = calc.call

    assert result[:valid]
    expected_lease_total = 2_000 + (350 * 36)
    assert_in_delta expected_lease_total, result[:total_lease_cost], 0.01
  end

  # --- Validation errors ---

  test "zero vehicle price returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 0, down_payment_buy: 0, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Vehicle price must be positive"
  end

  test "negative down payment returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: -1, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment cannot be negative"
  end

  test "down payment exceeding vehicle price returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 35_000, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment cannot exceed vehicle price"
  end

  test "negative loan rate returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 5_000, loan_rate_percent: -1,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan rate cannot be negative"
  end

  test "zero loan term returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 5_000, loan_rate_percent: 5,
      loan_term_months: 0, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  test "zero lease term returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 5_000, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 0,
      lease_down_payment: 0, estimated_resale_value: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Lease term must be positive"
  end

  test "negative resale value returns error" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 30_000, down_payment_buy: 5_000, loan_rate_percent: 5,
      loan_term_months: 60, lease_monthly_payment: 300, lease_term_months: 36,
      lease_down_payment: 0, estimated_resale_value: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Estimated resale value cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: "30000", down_payment_buy: "5000", loan_rate_percent: "5",
      loan_term_months: "60", lease_monthly_payment: "300", lease_term_months: "36",
      lease_down_payment: "1000", estimated_resale_value: "12000"
    )
    result = calc.call

    assert result[:valid]
    assert result[:buy_monthly_payment] > 0
  end

  # --- Large numbers ---

  test "very large vehicle price still computes" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 500_000, down_payment_buy: 100_000, loan_rate_percent: 4,
      loan_term_months: 84, lease_monthly_payment: 5_000, lease_term_months: 48,
      lease_down_payment: 10_000, estimated_resale_value: 200_000
    )
    result = calc.call

    assert result[:valid]
    assert result[:buy_monthly_payment] > 0
    assert result[:total_buy_cost] > 0
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::LeaseVsBuyCalculator.new(
      vehicle_price: 0, down_payment_buy: -1, loan_rate_percent: -1,
      loan_term_months: 0, lease_monthly_payment: -1, lease_term_months: 0,
      lease_down_payment: -1, estimated_resale_value: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 5
  end
end
