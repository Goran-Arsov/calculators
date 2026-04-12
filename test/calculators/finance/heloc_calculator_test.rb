require "test_helper"

class Finance::HelocCalculatorTest < ActiveSupport::TestCase
  test "happy path: standard HELOC calculation" do
    calc = Finance::HelocCalculator.new(
      home_value: 400_000, mortgage_balance: 250_000,
      credit_limit_percent: 80, annual_rate: 8.5,
      draw_amount: 50_000, repayment_years: 20
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 70_000, result[:available_equity], 0.01
    assert result[:monthly_payment] > 0
    assert result[:interest_only_payment] > 0
    assert result[:total_interest] > 0
    assert_equal 240, result[:num_payments]
  end

  test "available equity is zero when mortgage exceeds limit" do
    calc = Finance::HelocCalculator.new(
      home_value: 300_000, mortgage_balance: 250_000,
      credit_limit_percent: 80, annual_rate: 8,
      draw_amount: 10_000, repayment_years: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:available_equity], 0.01
  end

  test "zero interest rate divides draw evenly" do
    calc = Finance::HelocCalculator.new(
      home_value: 500_000, mortgage_balance: 200_000,
      credit_limit_percent: 80, annual_rate: 0,
      draw_amount: 120_000, repayment_years: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000, result[:monthly_payment], 0.01
    assert_in_delta 0, result[:total_interest], 0.01
    assert_in_delta 0, result[:interest_only_payment], 0.01
  end

  test "negative home value returns error" do
    calc = Finance::HelocCalculator.new(
      home_value: -100_000, mortgage_balance: 50_000,
      credit_limit_percent: 80, annual_rate: 8,
      draw_amount: 10_000, repayment_years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Home value must be positive"
  end

  test "negative mortgage balance returns error" do
    calc = Finance::HelocCalculator.new(
      home_value: 400_000, mortgage_balance: -50_000,
      credit_limit_percent: 80, annual_rate: 8,
      draw_amount: 10_000, repayment_years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Mortgage balance cannot be negative"
  end

  test "repayment years must be positive" do
    calc = Finance::HelocCalculator.new(
      home_value: 400_000, mortgage_balance: 250_000,
      credit_limit_percent: 80, annual_rate: 8,
      draw_amount: 50_000, repayment_years: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Repayment term must be positive"
  end

  test "string inputs are coerced" do
    calc = Finance::HelocCalculator.new(
      home_value: "400000", mortgage_balance: "250000",
      credit_limit_percent: "80", annual_rate: "8",
      draw_amount: "50000", repayment_years: "15"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  test "large values still compute" do
    calc = Finance::HelocCalculator.new(
      home_value: 10_000_000, mortgage_balance: 5_000_000,
      credit_limit_percent: 85, annual_rate: 7,
      draw_amount: 3_000_000, repayment_years: 30
    )
    result = calc.call

    assert result[:valid]
    assert result[:available_equity] > 0
    assert result[:monthly_payment] > 0
  end
end
