require "test_helper"

class Finance::SavingsInterestCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: initial balance with monthly deposits and interest" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 10
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 5_000 + (500 * 120)
    assert_equal 60_000.0, result[:total_deposits]
    assert result[:total_interest] > 0
    assert_in_delta 65_000.0, result[:total_contributions], 0.01
  end

  test "happy path: only initial balance, no deposits" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 10_000, monthly_deposit: 0, annual_rate: 5, years: 1
    )
    result = calc.call

    assert result[:valid]
    # Monthly compounding: should be slightly above simple 5%
    assert result[:future_value] > 10_000
    assert_in_delta 10_511.62, result[:future_value], 5.0
  end

  test "happy path: only monthly deposits, no initial balance" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 0, monthly_deposit: 1_000, annual_rate: 5, years: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 60_000.0, result[:total_deposits]
    assert result[:future_value] > 60_000
    assert result[:total_interest] > 0
  end

  # --- Zero interest ---

  test "zero interest rate just accumulates deposits" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 1_000, monthly_deposit: 100, annual_rate: 0, years: 5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 7_000.0, result[:future_value], 0.01  # 1000 + 100*60
    assert_in_delta 0.0, result[:total_interest], 0.01
  end

  # --- Zero / Negative values ---

  test "both zero initial and zero deposit returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 0, monthly_deposit: 0, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Either initial balance or monthly deposit must be positive"
  end

  test "negative initial balance returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: -1000, monthly_deposit: 500, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Initial balance cannot be negative"
  end

  test "negative monthly deposit returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: -100, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly deposit cannot be negative"
  end

  test "zero years returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Number of years must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: -2, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual interest rate cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: "5000", monthly_deposit: "500", annual_rate: "5", years: "10"
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 0
  end

  # --- Large numbers ---

  test "very large balance and deposit still compute" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 1_000_000, monthly_deposit: 50_000, annual_rate: 4, years: 30
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 1_000_000
  end

  # --- Yearly breakdown ---

  test "yearly breakdown has correct number of entries" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 1_000, monthly_deposit: 100, annual_rate: 5, years: 5
    )
    result = calc.call

    assert result[:valid]
    assert_equal 5, result[:yearly_breakdown].size
    assert_equal 1, result[:yearly_breakdown].first[:year]
    assert_equal 5, result[:yearly_breakdown].last[:year]
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: -1, monthly_deposit: -1, annual_rate: -1, years: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end

  # --- Inflation adjustment (optional) ---

  test "inflation: absent kwarg returns no real_* keys" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 10
    )
    result = calc.call

    assert result[:valid]
    refute result.key?(:real_future_value)
    refute result.key?(:real_total_interest)
    refute result.key?(:annual_inflation_rate)
  end

  test "inflation: zero rate makes real values equal nominal" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 10,
      annual_inflation_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:future_value], result[:real_future_value], 0.01
    assert_in_delta result[:total_interest], result[:real_total_interest], 0.01
  end

  test "inflation: 3% over 10 years reduces real values by compounded factor" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 10,
      annual_inflation_rate: 3
    )
    result = calc.call

    assert result[:valid]
    factor = 1.03**10
    assert_operator result[:real_future_value], :<, result[:future_value]
    assert_in_delta result[:future_value] / factor, result[:real_future_value], 0.01
    assert_in_delta result[:total_interest] / factor, result[:real_total_interest], 0.01
  end

  test "inflation: negative rate returns error" do
    calc = Finance::SavingsInterestCalculator.new(
      initial_balance: 5_000, monthly_deposit: 500, annual_rate: 5, years: 10,
      annual_inflation_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Inflation rate cannot be negative"
  end
end
