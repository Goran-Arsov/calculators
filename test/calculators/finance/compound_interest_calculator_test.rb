require "test_helper"

class Finance::CompoundInterestCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: monthly compounding for 10 years at 5%" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 5, years: 10, compounds_per_year: 12
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    # FV = 10000 * (1 + 0.05/12)^(12*10) = 16470.09
    assert_in_delta 16_470.09, result[:future_value], 1.0
    assert_in_delta 6_470.09, result[:total_interest], 1.0
    assert_in_delta 10_000.00, result[:principal], 0.01
  end

  test "happy path: annual compounding" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: 10, years: 5, compounds_per_year: 1
    )
    result = calc.call

    assert result[:valid]
    # FV = 5000 * (1.10)^5 = 8052.55
    assert_in_delta 8_052.55, result[:future_value], 0.01
  end

  test "happy path: daily compounding" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 1_000, annual_rate: 3, years: 1, compounds_per_year: 365
    )
    result = calc.call

    assert result[:valid]
    # FV = 1000 * (1 + 0.03/365)^365 ~ 1030.45
    assert_in_delta 1_030.45, result[:future_value], 0.1
  end

  test "happy path: defaults to monthly compounding" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 6, years: 5
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 10_000
  end

  # --- Zero interest rate ---

  test "zero interest rate returns principal unchanged" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 0, years: 10, compounds_per_year: 12
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.00, result[:future_value], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
  end

  test "zero interest rate with any compounding frequency returns principal" do
    [ 1, 4, 12, 365 ].each do |freq|
      calc = Finance::CompoundInterestCalculator.new(
        principal: 25_000, annual_rate: 0, years: 30, compounds_per_year: freq
      )
      result = calc.call

      assert result[:valid], "Expected valid for compounds_per_year=#{freq}"
      assert_in_delta 25_000.00, result[:future_value], 0.01,
        "Expected principal unchanged for compounds_per_year=#{freq}"
      assert_in_delta 0.00, result[:total_interest], 0.01,
        "Expected zero interest for compounds_per_year=#{freq}"
    end
  end

  # --- Negative values ---

  test "negative principal returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: -5_000, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "negative interest rate returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: -5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "negative years returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: 5, years: -3
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  test "negative compounds per year returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: 5, years: 10, compounds_per_year: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Compounding frequency must be positive"
  end

  # --- Zero values ---

  test "zero principal returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 0, annual_rate: 5, years: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Principal must be positive"
  end

  test "zero years returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: 5, years: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Time period must be positive"
  end

  test "zero compounds per year returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 5_000, annual_rate: 5, years: 10, compounds_per_year: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Compounding frequency must be positive"
  end

  # --- Large numbers ---

  test "very large principal still computes" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 1_000_000_000, annual_rate: 8, years: 50, compounds_per_year: 12
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 1_000_000_000
    assert result[:total_interest] > 0
  end

  test "very large years still computes" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 1_000, annual_rate: 2, years: 200, compounds_per_year: 1
    )
    result = calc.call

    assert result[:valid]
    assert result[:future_value] > 1_000
  end

  # --- Validation errors: multiple at once ---

  test "multiple validation errors returned at once" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: -1, annual_rate: -1, years: 0, compounds_per_year: 0
    )
    result = calc.call

    refute result[:valid]
    assert_equal 4, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: "10000", annual_rate: "5", years: "10", compounds_per_year: "12"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 16_470.09, result[:future_value], 1.0
  end

  # --- Edge case: quarterly compounding ---

  test "quarterly compounding produces correct result" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 8, years: 5, compounds_per_year: 4
    )
    result = calc.call

    assert result[:valid]
    # FV = 10000 * (1 + 0.08/4)^(4*5) = 10000 * (1.02)^20 = 14859.47
    assert_in_delta 14_859.47, result[:future_value], 1.0
  end

  # --- Inflation adjustment (optional) ---

  test "inflation: absent kwarg returns no real_* keys" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 5, years: 10
    )
    result = calc.call

    assert result[:valid]
    refute result.key?(:real_future_value)
    refute result.key?(:real_total_interest)
    refute result.key?(:annual_inflation_rate)
  end

  test "inflation: zero rate makes real values equal nominal" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 5, years: 10, annual_inflation_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:future_value], result[:real_future_value], 0.01
    assert_in_delta result[:total_interest], result[:real_total_interest], 0.01
    assert_in_delta 0.0, result[:annual_inflation_rate], 0.01
  end

  test "inflation: 3% over 10 years reduces real values by compounded factor" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 5, years: 10, annual_inflation_rate: 3
    )
    result = calc.call

    assert result[:valid]
    factor = 1.03**10
    assert_operator result[:real_future_value], :<, result[:future_value]
    assert_in_delta result[:future_value] / factor, result[:real_future_value], 0.01
    assert_in_delta result[:total_interest] / factor, result[:real_total_interest], 0.01
  end

  test "inflation: negative rate returns error" do
    calc = Finance::CompoundInterestCalculator.new(
      principal: 10_000, annual_rate: 5, years: 10, annual_inflation_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Inflation rate cannot be negative"
  end
end
