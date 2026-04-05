require "test_helper"

class Finance::FourOhOneKCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: typical 401k projection" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 50_000,
      annual_contribution: 19_500,
      employer_match_percent: 50,
      employer_match_limit: 100,
      annual_return: 7,
      years_to_retirement: 25
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 50_000 + (19_500 * 25)
    assert_equal 25, result[:years]
    assert_in_delta 9_750.0, result[:employer_annual_match], 0.01
    assert result[:total_contributions] > 0
    assert result[:total_employer_match] > 0
    assert result[:total_growth] > 0
  end

  test "happy path: no employer match" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 0,
      annual_contribution: 10_000,
      employer_match_percent: 0,
      employer_match_limit: 0,
      annual_return: 7,
      years_to_retirement: 30
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:employer_annual_match], 0.01
    assert_in_delta 0.0, result[:total_employer_match], 0.01
    assert result[:future_value] > 300_000
  end

  test "happy path: zero starting balance" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 0,
      annual_contribution: 23_000,
      employer_match_percent: 100,
      employer_match_limit: 50,
      annual_return: 8,
      years_to_retirement: 20
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0.0, result[:current_balance]
    assert_in_delta 11_500.0, result[:employer_annual_match], 0.01
  end

  # --- Zero / Negative values ---

  test "zero contribution returns error" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 50_000, annual_contribution: 0,
      employer_match_percent: 50, employer_match_limit: 100,
      annual_return: 7, years_to_retirement: 25
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual contribution must be positive"
  end

  test "negative current balance returns error" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: -1000, annual_contribution: 10_000,
      employer_match_percent: 50, employer_match_limit: 100,
      annual_return: 7, years_to_retirement: 25
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current balance cannot be negative"
  end

  test "zero years returns error" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 50_000, annual_contribution: 10_000,
      employer_match_percent: 50, employer_match_limit: 100,
      annual_return: 7, years_to_retirement: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Years to retirement must be positive"
  end

  test "negative return rate returns error" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 50_000, annual_contribution: 10_000,
      employer_match_percent: 50, employer_match_limit: 100,
      annual_return: -5, years_to_retirement: 25
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual return rate cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: "50000", annual_contribution: "19500",
      employer_match_percent: "50", employer_match_limit: "100",
      annual_return: "7", years_to_retirement: "25"
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 0
  end

  # --- Zero return rate ---

  test "zero return rate still accumulates contributions" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 10_000, annual_contribution: 10_000,
      employer_match_percent: 100, employer_match_limit: 100,
      annual_return: 0, years_to_retirement: 10
    )
    result = calc.call

    assert result[:valid]
    # With 0% return: 10000 + (10000 + 10000) * 10 = 210000
    assert_in_delta 210_000.0, result[:future_value], 0.01
    assert_in_delta 0.0, result[:total_growth], 0.01
  end

  # --- Large numbers ---

  test "very large contributions still compute" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 1_000_000, annual_contribution: 50_000,
      employer_match_percent: 100, employer_match_limit: 100,
      annual_return: 10, years_to_retirement: 40
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 10_000_000
  end

  # --- Year by year data ---

  test "year_by_year returns correct number of entries" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: 0, annual_contribution: 10_000,
      employer_match_percent: 50, employer_match_limit: 100,
      annual_return: 7, years_to_retirement: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5, result[:year_by_year].size
    assert_equal 1, result[:year_by_year].first[:year]
    assert_equal 5, result[:year_by_year].last[:year]
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::FourOhOneKCalculator.new(
      current_balance: -1, annual_contribution: 0,
      employer_match_percent: -1, employer_match_limit: -1,
      annual_return: -1, years_to_retirement: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end
end
