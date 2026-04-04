require "test_helper"

class Finance::DividendYieldCalculatorTest < ActiveSupport::TestCase
  # --- Solve for yield ---

  test "price=50, dividend=2 → yield=4%" do
    result = Finance::DividendYieldCalculator.new(share_price: 50, annual_dividend: 2).call
    assert result[:valid]
    assert_equal 4.0, result[:yield_pct]
    assert_equal :yield_pct, result[:solved_for]
  end

  test "price=100, dividend=5 → yield=5%" do
    result = Finance::DividendYieldCalculator.new(share_price: 100, annual_dividend: 5).call
    assert result[:valid]
    assert_equal 5.0, result[:yield_pct]
  end

  # --- Solve for dividend ---

  test "solve for dividend: price=50, yield=4% → dividend=2" do
    result = Finance::DividendYieldCalculator.new(share_price: 50, yield_pct: 4).call
    assert result[:valid]
    assert_equal 2.0, result[:annual_dividend]
    assert_equal :annual_dividend, result[:solved_for]
  end

  # --- Solve for price ---

  test "solve for price: dividend=2, yield=4% → price=50" do
    result = Finance::DividendYieldCalculator.new(annual_dividend: 2, yield_pct: 4).call
    assert result[:valid]
    assert_equal 50.0, result[:share_price]
    assert_equal :share_price, result[:solved_for]
  end

  # --- Validation errors ---

  test "error when fewer than 2 values provided" do
    result = Finance::DividendYieldCalculator.new(share_price: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Exactly 2 of share_price, annual_dividend, and yield_pct must be provided"
  end

  test "error when share price is negative" do
    result = Finance::DividendYieldCalculator.new(share_price: -10, annual_dividend: 2).call
    refute result[:valid]
    assert_includes result[:errors], "Share price must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::DividendYieldCalculator.new(share_price: 50, annual_dividend: 2)
    assert_equal [], calc.errors
  end
end
