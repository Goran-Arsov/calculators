require "test_helper"

class Finance::StockProfitCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: profitable trade with no fees" do
    calc = Finance::StockProfitCalculator.new(buy_price: 50, sell_price: 75, shares: 100)
    result = calc.call

    assert result[:valid]
    assert_in_delta 5_000.0, result[:total_cost], 0.01
    assert_in_delta 7_500.0, result[:total_revenue], 0.01
    assert_in_delta 2_500.0, result[:profit], 0.01
    assert_in_delta 50.0, result[:roi], 0.01
    assert_in_delta 50.0, result[:percent_change], 0.01
  end

  test "happy path: profitable trade with commissions" do
    calc = Finance::StockProfitCalculator.new(
      buy_price: 100, sell_price: 150, shares: 50,
      buy_commission: 9.99, sell_commission: 9.99
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 5_009.99, result[:total_cost], 0.01
    assert_in_delta 7_490.01, result[:total_revenue], 0.01
    assert_in_delta 2_480.02, result[:profit], 0.01
    assert_in_delta 19.98, result[:total_fees], 0.01
  end

  test "happy path: losing trade" do
    calc = Finance::StockProfitCalculator.new(buy_price: 100, sell_price: 80, shares: 100)
    result = calc.call

    assert result[:valid]
    assert result[:profit] < 0
    assert result[:roi] < 0
    assert_in_delta 0.0, result[:capital_gains_tax], 0.01  # No tax on losses
  end

  # --- Capital gains ---

  test "long-term capital gains rate is 15%" do
    calc = Finance::StockProfitCalculator.new(
      buy_price: 100, sell_price: 200, shares: 100, holding_period: "long"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000 * 0.15, result[:capital_gains_tax], 0.01
    assert_equal "long", result[:holding_period]
  end

  test "short-term capital gains rate is 24%" do
    calc = Finance::StockProfitCalculator.new(
      buy_price: 100, sell_price: 200, shares: 100, holding_period: "short"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000 * 0.24, result[:capital_gains_tax], 0.01
    assert_equal "short", result[:holding_period]
  end

  # --- Break-even price ---

  test "break-even price accounts for fees" do
    calc = Finance::StockProfitCalculator.new(
      buy_price: 100, sell_price: 120, shares: 100,
      buy_commission: 10, sell_commission: 10
    )
    result = calc.call

    assert result[:valid]
    # Break even = (100*100 + 10 + 10) / 100 = 100.20
    assert_in_delta 100.20, result[:break_even_price], 0.01
  end

  # --- Zero / Negative values ---

  test "zero buy price returns error" do
    calc = Finance::StockProfitCalculator.new(buy_price: 0, sell_price: 50, shares: 100)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Buy price must be positive"
  end

  test "zero shares returns error" do
    calc = Finance::StockProfitCalculator.new(buy_price: 50, sell_price: 75, shares: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Number of shares must be positive"
  end

  test "negative commission returns error" do
    calc = Finance::StockProfitCalculator.new(buy_price: 50, sell_price: 75, shares: 100, buy_commission: -5)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Buy commission cannot be negative"
  end

  test "invalid holding period returns error" do
    calc = Finance::StockProfitCalculator.new(buy_price: 50, sell_price: 75, shares: 100, holding_period: "medium")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Holding period must be 'short' or 'long'"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::StockProfitCalculator.new(buy_price: "50", sell_price: "75", shares: "100")
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_500.0, result[:profit], 0.01
  end

  # --- Large numbers ---

  test "very large share count still computes" do
    calc = Finance::StockProfitCalculator.new(buy_price: 1, sell_price: 2, shares: 10_000_000)
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000_000.0, result[:profit], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::StockProfitCalculator.new(
      buy_price: -1, sell_price: -1, shares: -1,
      buy_commission: -1, sell_commission: -1, holding_period: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 5
  end
end
