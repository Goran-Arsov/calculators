require "test_helper"

class Finance::EarningsPerShareCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic EPS: income=10M, dividends=1M, shares=1M -> EPS=$9.00" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 1_000_000, shares_outstanding: 1_000_000).call
    assert result[:valid]
    assert_equal 9.0, result[:basic_eps]
    assert_equal 9_000_000.0, result[:earnings_available]
  end

  test "EPS with stock price calculates P/E ratio and earnings yield" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000, stock_price: 50).call
    assert result[:valid]
    assert_equal 10.0, result[:basic_eps]
    assert_equal 5.0, result[:pe_ratio]
    assert_equal 20.0, result[:earnings_yield]
  end

  test "zero preferred dividends" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 5_000_000, preferred_dividends: 0, shares_outstanding: 500_000).call
    assert result[:valid]
    assert_equal 10.0, result[:basic_eps]
  end

  test "negative net income yields negative EPS" do
    result = Finance::EarningsPerShareCalculator.new(net_income: -2_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000).call
    assert result[:valid]
    assert_equal(-2.0, result[:basic_eps])
  end

  test "string coercion works for numeric inputs" do
    result = Finance::EarningsPerShareCalculator.new(net_income: "10000000", preferred_dividends: "0", shares_outstanding: "1000000").call
    assert result[:valid]
    assert_equal 10.0, result[:basic_eps]
  end

  test "P/E ratio not calculated when EPS is negative" do
    result = Finance::EarningsPerShareCalculator.new(net_income: -2_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000, stock_price: 50).call
    assert result[:valid]
    refute result.key?(:pe_ratio)
  end

  # --- Without optional stock price ---

  test "result does not include P/E ratio without stock price" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000).call
    assert result[:valid]
    refute result.key?(:pe_ratio)
    refute result.key?(:earnings_yield)
  end

  # --- Validation errors ---

  test "error when shares outstanding is zero" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 0, shares_outstanding: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Shares outstanding must be positive"
  end

  test "error when preferred dividends are negative" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: -100, shares_outstanding: 1_000_000).call
    refute result[:valid]
    assert_includes result[:errors], "Preferred dividends cannot be negative"
  end

  test "error when preferred dividends exceed net income" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 1_000_000, preferred_dividends: 2_000_000, shares_outstanding: 1_000_000).call
    refute result[:valid]
    assert_includes result[:errors], "Preferred dividends cannot exceed net income"
  end

  test "error when stock price is negative" do
    result = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000, stock_price: -10).call
    refute result[:valid]
    assert_includes result[:errors], "Stock price must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::EarningsPerShareCalculator.new(net_income: 10_000_000, preferred_dividends: 0, shares_outstanding: 1_000_000)
    assert_equal [], calc.errors
  end
end
