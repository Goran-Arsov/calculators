require "test_helper"

class Finance::AmortizationCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: 30-year mortgage at 6%" do
    calc = Finance::AmortizationCalculator.new(principal: 300_000, annual_rate: 6, years: 30)
    result = calc.call

    assert result[:valid]
    assert_in_delta 1798.65, result[:monthly_payment], 0.01
    assert_equal 360, result[:num_payments]
    assert_equal 360, result[:schedule].size
    assert_in_delta 300_000.0, result[:principal], 0.01
  end

  test "happy path: schedule starts with high interest, ends with high principal" do
    calc = Finance::AmortizationCalculator.new(principal: 200_000, annual_rate: 5, years: 30)
    result = calc.call

    assert result[:valid]
    first = result[:schedule].first
    last = result[:schedule].last
    # First payment: more interest than principal
    assert first[:interest] > first[:principal]
    # Last payment: balance should be zero
    assert_in_delta 0.0, last[:balance], 0.01
  end

  test "happy path: 15-year loan" do
    calc = Finance::AmortizationCalculator.new(principal: 100_000, annual_rate: 4, years: 15)
    result = calc.call

    assert result[:valid]
    assert_equal 180, result[:schedule].size
    assert_in_delta 739.69, result[:monthly_payment], 0.01
  end

  # --- Zero interest ---

  test "zero interest rate produces even principal payments" do
    calc = Finance::AmortizationCalculator.new(principal: 12_000, annual_rate: 0, years: 1)
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.0, result[:monthly_payment], 0.01
    assert_in_delta 0.0, result[:total_interest], 0.01
    result[:schedule].each do |row|
      assert_in_delta 0.0, row[:interest], 0.01
    end
  end

  # --- Negative / Zero values ---

  test "zero principal returns error" do
    calc = Finance::AmortizationCalculator.new(principal: 0, annual_rate: 5, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "negative principal returns error" do
    calc = Finance::AmortizationCalculator.new(principal: -100_000, annual_rate: 5, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "zero years returns error" do
    calc = Finance::AmortizationCalculator.new(principal: 100_000, annual_rate: 5, years: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::AmortizationCalculator.new(principal: 100_000, annual_rate: -3, years: 30)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::AmortizationCalculator.new(principal: "200000", annual_rate: "5.5", years: "30")
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_equal 360, result[:schedule].size
  end

  # --- Large numbers ---

  test "very large principal still computes" do
    calc = Finance::AmortizationCalculator.new(principal: 50_000_000, annual_rate: 4, years: 30)
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_equal 360, result[:schedule].size
    assert_in_delta 0.0, result[:schedule].last[:balance], 1.0
  end

  # --- Schedule integrity ---

  test "all schedule balances are non-negative" do
    calc = Finance::AmortizationCalculator.new(principal: 100_000, annual_rate: 6, years: 15)
    result = calc.call

    assert result[:valid]
    result[:schedule].each do |row|
      assert row[:balance] >= 0, "Balance should not be negative at month #{row[:month]}"
    end
  end

  test "schedule months are sequential" do
    calc = Finance::AmortizationCalculator.new(principal: 50_000, annual_rate: 8, years: 5)
    result = calc.call

    assert result[:valid]
    result[:schedule].each_with_index do |row, i|
      assert_equal i + 1, row[:month]
    end
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::AmortizationCalculator.new(principal: -1, annual_rate: -1, years: 0)
    result = calc.call

    refute result[:valid]
    assert_equal 3, calc.errors.size
  end
end
