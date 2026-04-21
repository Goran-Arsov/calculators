require "test_helper"

class Finance::FireCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard FIRE calculation with 4% SWR" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_in_delta 1_000_000.0, result[:fire_number], 0.01
    assert result[:years_to_fire] > 0
    assert result[:monthly_savings_needed] >= 0
    assert_in_delta 1_000_000.0, result[:projected_portfolio_at_fire], 0.01
  end

  test "happy path: custom safe withdrawal rate" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 50_000, annual_savings: 40_000,
      current_portfolio: 200_000, expected_return_rate: 8,
      safe_withdrawal_rate: 3.5
    )
    result = calc.call

    assert result[:valid]
    expected_fire = 50_000 / 0.035
    assert_in_delta expected_fire, result[:fire_number], 0.01
  end

  test "happy path: already reached FIRE number" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 1_200_000, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:years_to_fire]
    assert_in_delta 0.0, result[:monthly_savings_needed], 0.01
    assert_in_delta 1_200_000.0, result[:projected_portfolio_at_fire], 0.01
  end

  test "fire number equals annual expenses divided by SWR" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 60_000, annual_savings: 20_000,
      current_portfolio: 50_000, expected_return_rate: 5
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_500_000.0, result[:fire_number], 0.01
  end

  # --- Zero return rate ---

  test "zero return rate calculates years using simple division" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 50_000,
      current_portfolio: 100_000, expected_return_rate: 0
    )
    result = calc.call

    assert result[:valid]
    # FIRE number = 1,000,000. Gap = 900,000. Years = ceil(900000/50000) = 18
    assert_equal 18, result[:years_to_fire]
  end

  # --- Negative values ---

  test "negative annual expenses returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: -40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual expenses must be positive"
  end

  test "negative annual savings returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: -10_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual savings cannot be negative"
  end

  test "negative current portfolio returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: -50_000, expected_return_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Current portfolio cannot be negative"
  end

  test "negative expected return rate returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: -5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Expected return rate cannot be negative"
  end

  test "zero safe withdrawal rate returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7,
      safe_withdrawal_rate: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Safe withdrawal rate must be positive"
  end

  # --- Zero values ---

  test "zero annual expenses returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 0, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual expenses must be positive"
  end

  test "zero annual savings with sufficient portfolio still works" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 0,
      current_portfolio: 1_500_000, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:years_to_fire]
  end

  test "zero current portfolio with savings computes years" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 50_000,
      current_portfolio: 0, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    assert result[:years_to_fire] > 0
  end

  # --- Large numbers ---

  test "very large portfolio already at FIRE" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 100_000, annual_savings: 50_000,
      current_portfolio: 10_000_000, expected_return_rate: 10
    )
    result = calc.call

    assert result[:valid]
    assert_equal 0, result[:years_to_fire]
  end

  test "very large expenses require large FIRE number" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 200_000, annual_savings: 100_000,
      current_portfolio: 500_000, expected_return_rate: 8
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 5_000_000.0, result[:fire_number], 0.01
    assert result[:years_to_fire] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::FireCalculator.new(
      annual_expenses: -1, annual_savings: -1,
      current_portfolio: -1, expected_return_rate: -1,
      safe_withdrawal_rate: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::FireCalculator.new(
      annual_expenses: "40000", annual_savings: "30000",
      current_portfolio: "100000", expected_return_rate: "7",
      safe_withdrawal_rate: "4"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000_000.0, result[:fire_number], 0.01
  end

  # --- Default SWR ---

  test "default safe withdrawal rate is 4 percent" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    # FIRE number with 4% SWR = 40000 / 0.04 = 1,000,000
    assert_in_delta 1_000_000.0, result[:fire_number], 0.01
  end

  # --- Inflation adjustment (optional) ---

  test "inflation: absent kwarg returns no real_* keys" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7
    )
    result = calc.call

    assert result[:valid]
    refute result.key?(:real_fire_number)
    refute result.key?(:real_projected_portfolio_at_fire)
    refute result.key?(:annual_inflation_rate)
  end

  test "inflation: zero rate makes real values equal nominal" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7, annual_inflation_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta result[:fire_number], result[:real_fire_number], 0.01
    assert_in_delta result[:projected_portfolio_at_fire], result[:real_projected_portfolio_at_fire], 0.01
  end

  test "inflation: 3% over years-to-fire reduces real values by compounded factor" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7, annual_inflation_rate: 3
    )
    result = calc.call

    assert result[:valid]
    factor = (1.03)**result[:years_to_fire]
    assert_operator result[:real_fire_number], :<, result[:fire_number]
    assert_in_delta result[:fire_number] / factor, result[:real_fire_number], 0.01
    assert_in_delta result[:projected_portfolio_at_fire] / factor, result[:real_projected_portfolio_at_fire], 0.01
  end

  test "inflation: negative rate returns error" do
    calc = Finance::FireCalculator.new(
      annual_expenses: 40_000, annual_savings: 30_000,
      current_portfolio: 100_000, expected_return_rate: 7, annual_inflation_rate: -1
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Inflation rate cannot be negative"
  end
end
