require "test_helper"

class Finance::OptionsProfitCalculatorTest < ActiveSupport::TestCase
  test "call option in the money" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 150, premium: 5,
      underlying_price: 160, contracts: 1
    )
    result = calc.call

    assert result[:valid]
    assert_equal "call", result[:option_type]
    assert_in_delta 5.0, result[:profit_per_share], 0.01
    assert_in_delta 500.0, result[:total_profit], 0.01
    assert_in_delta 155.0, result[:break_even], 0.01
    assert_in_delta 500.0, result[:total_premium_paid], 0.01
    assert_in_delta 500.0, result[:max_loss], 0.01
    assert_equal "Unlimited", result[:max_profit]
    assert result[:in_the_money]
  end

  test "call option out of the money" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 150, premium: 5,
      underlying_price: 140, contracts: 1
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta(-5.0, result[:profit_per_share], 0.01)
    assert_in_delta(-500.0, result[:total_profit], 0.01)
    refute result[:in_the_money]
  end

  test "put option in the money" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "put", strike_price: 150, premium: 5,
      underlying_price: 140, contracts: 2
    )
    result = calc.call

    assert result[:valid]
    assert_equal "put", result[:option_type]
    assert_in_delta 5.0, result[:profit_per_share], 0.01
    assert_in_delta 1_000.0, result[:total_profit], 0.01
    assert_in_delta 145.0, result[:break_even], 0.01
    assert result[:in_the_money]
    assert result[:max_profit].is_a?(Numeric)
  end

  test "put option out of the money" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "put", strike_price: 150, premium: 5,
      underlying_price: 160, contracts: 1
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta(-5.0, result[:profit_per_share], 0.01)
    refute result[:in_the_money]
  end

  test "multiple contracts multiply correctly" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 100, premium: 3,
      underlying_price: 110, contracts: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 500, result[:total_shares]
    assert_in_delta 3_500.0, result[:total_profit], 0.01
    assert_in_delta 1_500.0, result[:total_premium_paid], 0.01
  end

  test "invalid option type returns error" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "straddle", strike_price: 150, premium: 5,
      underlying_price: 160, contracts: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Option type must be 'call' or 'put'"
  end

  test "zero strike price returns error" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 0, premium: 5,
      underlying_price: 160, contracts: 1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Strike price must be positive"
  end

  test "zero contracts returns error" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 150, premium: 5,
      underlying_price: 160, contracts: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Number of contracts must be positive"
  end

  test "ROI calculation" do
    calc = Finance::OptionsProfitCalculator.new(
      option_type: "call", strike_price: 100, premium: 5,
      underlying_price: 115, contracts: 1
    )
    result = calc.call

    assert result[:valid]
    # Profit: (115 - 100 - 5) * 100 = $1000, premium paid: $500
    assert_in_delta 200.0, result[:roi], 0.01
  end
end
