require "test_helper"

class Finance::DownPaymentCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard 20% down payment" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 80_000.0, result[:down_payment_target], 0.01
    assert_in_delta 60_000.0, result[:savings_gap], 0.01
    assert result[:months_to_save] > 0
    assert result[:years_to_save] > 0
    assert result[:total_with_interest] >= 80_000.0
  end

  test "happy path: 10% down payment" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 300_000, down_payment_percent: 10,
      current_savings: 10_000, monthly_savings: 1_500,
      annual_return_rate: 4
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 30_000.0, result[:down_payment_target], 0.01
    assert_in_delta 20_000.0, result[:savings_gap], 0.01
  end

  test "already saved enough" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 300_000, down_payment_percent: 20,
      current_savings: 100_000, monthly_savings: 1_000,
      annual_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 60_000.0, result[:down_payment_target], 0.01
    assert_in_delta 0.0, result[:savings_gap], 0.01
    assert_equal 0, result[:months_to_save]
    assert_in_delta 0.0, result[:years_to_save], 0.01
  end

  test "default down payment percent is 20" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 500_000,
      current_savings: 10_000, monthly_savings: 3_000,
      annual_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 100_000.0, result[:down_payment_target], 0.01
  end

  # --- Zero return rate ---

  test "zero return rate uses simple savings calculation" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 200_000, down_payment_percent: 20,
      current_savings: 10_000, monthly_savings: 1_000,
      annual_return_rate: 0
    )
    result = calc.call

    assert result[:valid]
    # Target = 40000, gap = 30000, months = ceil(30000/1000) = 30
    assert_equal 30, result[:months_to_save]
    assert_in_delta 2.5, result[:years_to_save], 0.01
  end

  # --- Negative values ---

  test "negative home price returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: -400_000, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Home price must be positive"
  end

  test "negative down payment percent returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: -10,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment percent must be positive"
  end

  test "down payment percent over 100 returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 110,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment percent cannot exceed 100"
  end

  test "negative current savings returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 20,
      current_savings: -10_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current savings cannot be negative"
  end

  test "negative monthly savings returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: -500,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly savings must be positive"
  end

  test "negative annual return rate returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: -3
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual return rate cannot be negative"
  end

  # --- Zero values ---

  test "zero home price returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 0, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Home price must be positive"
  end

  test "zero current savings is valid" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 300_000, down_payment_percent: 20,
      current_savings: 0, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 60_000.0, result[:savings_gap], 0.01
    assert result[:months_to_save] > 0
  end

  test "zero monthly savings returns error" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 300_000, down_payment_percent: 20,
      current_savings: 10_000, monthly_savings: 0,
      annual_return_rate: 5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly savings must be positive"
  end

  # --- Large numbers ---

  test "very large home price computes correctly" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 5_000_000, down_payment_percent: 20,
      current_savings: 100_000, monthly_savings: 10_000,
      annual_return_rate: 6
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000_000.0, result[:down_payment_target], 0.01
    assert result[:months_to_save] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: -1, down_payment_percent: -1,
      current_savings: -1, monthly_savings: -1,
      annual_return_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: "400000", down_payment_percent: "20",
      current_savings: "20000", monthly_savings: "2000",
      annual_return_rate: "5"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 80_000.0, result[:down_payment_target], 0.01
  end

  # --- Total with interest ---

  test "total with interest exceeds target when return rate is positive" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 400_000, down_payment_percent: 20,
      current_savings: 20_000, monthly_savings: 2_000,
      annual_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert result[:total_with_interest] >= result[:down_payment_target]
  end

  # --- Years to save matches months ---

  test "years to save equals months divided by 12" do
    calc = Finance::DownPaymentCalculator.new(
      home_price: 300_000, down_payment_percent: 20,
      current_savings: 10_000, monthly_savings: 1_500,
      annual_return_rate: 4
    )
    result = calc.call

    assert result[:valid]
    expected_years = result[:months_to_save] / 12.0
    assert_in_delta expected_years, result[:years_to_save], 0.1
  end
end
