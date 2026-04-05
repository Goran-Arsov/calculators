require "test_helper"

class Finance::CryptoProfitCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: profitable BTC trade with fees" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 30_000, sell_price: 45_000, quantity: 0.5,
      buy_fee_percent: 0.5, sell_fee_percent: 0.5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 15_000.0, result[:cost_basis], 0.01
    assert_in_delta 15_075.0, result[:total_cost], 0.01   # 15000 + 75
    assert_in_delta 22_500.0, result[:gross_revenue], 0.01
    assert_in_delta 22_387.50, result[:net_revenue], 0.01  # 22500 - 112.50
    assert result[:profit] > 0
    assert result[:roi] > 0
    assert_in_delta 50.0, result[:percent_change], 0.01
  end

  test "happy path: no fees" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 100, sell_price: 200, quantity: 10,
      buy_fee_percent: 0, sell_fee_percent: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.0, result[:profit], 0.01
    assert_in_delta 100.0, result[:roi], 0.01
    assert_in_delta 0.0, result[:total_fees], 0.01
  end

  test "happy path: losing trade" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 50_000, sell_price: 30_000, quantity: 1.0,
      buy_fee_percent: 0.5, sell_fee_percent: 0.5
    )
    result = calc.call

    assert result[:valid]
    assert result[:profit] < 0
    assert result[:roi] < 0
    assert_in_delta 0.0, result[:capital_gains_tax], 0.01  # No tax on losses
  end

  # --- Capital gains ---

  test "long-term capital gains rate is 15%" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 100, sell_price: 200, quantity: 10,
      buy_fee_percent: 0, sell_fee_percent: 0, holding_period: "long"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000 * 0.15, result[:capital_gains_tax], 0.01
  end

  test "short-term capital gains rate is 24%" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 100, sell_price: 200, quantity: 10,
      buy_fee_percent: 0, sell_fee_percent: 0, holding_period: "short"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000 * 0.24, result[:capital_gains_tax], 0.01
  end

  # --- Break-even price ---

  test "break-even price accounts for fees" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 30_000, sell_price: 45_000, quantity: 1.0,
      buy_fee_percent: 1, sell_fee_percent: 1
    )
    result = calc.call

    assert result[:valid]
    # Break even = (30000 + 300 + 30000*0.01*sell) / 1
    # total_cost = 30300, break_even = (30300 + 30300*0.01) / 1 = 30603
    assert_in_delta 30_603.0, result[:break_even_price], 1.0
  end

  # --- Zero / Negative values ---

  test "zero buy price returns error" do
    calc = Finance::CryptoProfitCalculator.new(buy_price: 0, sell_price: 45_000, quantity: 1)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Buy price must be positive"
  end

  test "zero quantity returns error" do
    calc = Finance::CryptoProfitCalculator.new(buy_price: 30_000, sell_price: 45_000, quantity: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Quantity must be positive"
  end

  test "negative buy fee returns error" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 30_000, sell_price: 45_000, quantity: 1, buy_fee_percent: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Buy fee percent cannot be negative"
  end

  test "invalid holding period returns error" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 30_000, sell_price: 45_000, quantity: 1, holding_period: "medium"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Holding period must be 'short' or 'long'"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: "30000", sell_price: "45000", quantity: "0.5"
    )
    result = calc.call

    assert result[:valid]
    assert result[:profit] > 0
  end

  # --- Fractional quantities ---

  test "fractional quantities work correctly" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 60_000, sell_price: 80_000, quantity: 0.001,
      buy_fee_percent: 0, sell_fee_percent: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 60.0, result[:cost_basis], 0.01
    assert_in_delta 80.0, result[:gross_revenue], 0.01
    assert_in_delta 20.0, result[:profit], 0.01
  end

  # --- Large numbers ---

  test "very large quantity still computes" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: 0.001, sell_price: 0.002, quantity: 10_000_000
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.0, result[:profit], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::CryptoProfitCalculator.new(
      buy_price: -1, sell_price: -1, quantity: -1,
      buy_fee_percent: -1, sell_fee_percent: -1, holding_period: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 5
  end
end
