require "test_helper"

class Finance::InvestmentCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: initial investment plus monthly contributions at 7%" do
    calc = Finance::InvestmentCalculator.new(
      initial: 10_000, monthly_contribution: 500, annual_rate: 7, years: 20
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors

    # Total contributions = 10000 + 500*240 = 130000
    assert_in_delta 130_000.00, result[:total_contributions], 0.01

    # FV should be significantly more than contributions due to compound growth
    assert result[:future_value] > 130_000
    assert result[:total_growth] > 0
    # FV ~ 10000*(1+0.07/12)^240 + 500*((1+0.07/12)^240-1)/(0.07/12)
    # ~ 40457.14 + 260464.26 = 300921.40
    assert_in_delta 300_921.40, result[:future_value], 100.0
  end

  test "happy path: only initial investment, no monthly contribution" do
    calc = Finance::InvestmentCalculator.new(
      initial: 50_000, monthly_contribution: 0, annual_rate: 5, years: 10
    )
    result = calc.call

    # Validation requires at least one of initial or monthly to be positive
    # Here initial is positive, monthly is zero -- should be valid
    assert result[:valid]
    # FV = 50000 * (1 + 0.05/12)^120
    assert_in_delta 82_350.47, result[:future_value], 1.0
  end

  test "happy path: no initial investment, only monthly contribution" do
    calc = Finance::InvestmentCalculator.new(
      initial: 0, monthly_contribution: 1_000, annual_rate: 8, years: 30
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 360_000.00, result[:total_contributions], 0.01
    assert result[:future_value] > 360_000
  end

  # --- Zero interest rate ---

  test "zero interest rate: future value equals total contributions" do
    calc = Finance::InvestmentCalculator.new(
      initial: 5_000, monthly_contribution: 200, annual_rate: 0, years: 10
    )
    result = calc.call

    assert result[:valid]
    expected = 5_000 + 200 * 120
    assert_in_delta expected.to_f, result[:future_value], 0.01
    assert_in_delta expected.to_f, result[:total_contributions], 0.01
    assert_in_delta 0.0, result[:total_growth], 0.01
  end

  # --- Negative values ---

  test "negative initial investment returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: -5_000, monthly_contribution: 100, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Initial investment cannot be negative"
  end

  test "negative monthly contribution returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: 5_000, monthly_contribution: -100, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly contribution cannot be negative"
  end

  test "negative interest rate returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: 5_000, monthly_contribution: 100, annual_rate: -5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative years returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: 5_000, monthly_contribution: 100, annual_rate: 5, years: -5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  # --- Zero values ---

  test "zero initial and zero monthly returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: 0, monthly_contribution: 0, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Initial investment or monthly contribution must be positive"
  end

  test "zero years returns error" do
    calc = Finance::InvestmentCalculator.new(
      initial: 5_000, monthly_contribution: 100, annual_rate: 5, years: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  # --- Large numbers ---

  test "very large initial investment still computes" do
    calc = Finance::InvestmentCalculator.new(
      initial: 1_000_000_000, monthly_contribution: 0, annual_rate: 10, years: 50
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 1_000_000_000
  end

  test "very large monthly contribution still computes" do
    calc = Finance::InvestmentCalculator.new(
      initial: 0, monthly_contribution: 1_000_000, annual_rate: 5, years: 40
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 0
    assert result[:total_contributions] > 0
  end

  # --- Validation errors: multiple at once ---

  test "multiple validation errors returned at once" do
    calc = Finance::InvestmentCalculator.new(
      initial: -1, monthly_contribution: -1, annual_rate: -1, years: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::InvestmentCalculator.new(
      initial: "10000", monthly_contribution: "500", annual_rate: "7", years: "20"
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 0
  end

  # --- Edge case ---

  test "one year with no interest and only contributions" do
    calc = Finance::InvestmentCalculator.new(
      initial: 1_000, monthly_contribution: 100, annual_rate: 0, years: 1
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_200.00, result[:future_value], 0.01
    assert_in_delta 2_200.00, result[:total_contributions], 0.01
    assert_in_delta 0.0, result[:total_growth], 0.01
  end
end
