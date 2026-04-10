require "test_helper"

class Finance::PensionCalculatorTest < ActiveSupport::TestCase
  DEFAULTS = {
    current_age: 30,
    retirement_age: 65,
    current_savings: 50_000,
    monthly_contribution: 500,
    annual_return_rate: 7,
    annual_inflation_rate: 2.5,
    years_in_retirement: 25
  }.freeze

  # --- Happy path ---

  test "happy path: 30 to 65 with inflation" do
    result = Finance::PensionCalculator.new(**DEFAULTS).call

    assert result[:valid]
    assert_equal 35, result[:years_to_retire]

    # Total contributions = 50000 + 500 * 420 = 260000
    assert_in_delta 260_000.00, result[:total_contributions], 0.01

    # Nominal pot should exceed contributions due to compound growth
    assert result[:nominal_pot] > 260_000

    # Real pot should be less than nominal pot because of inflation
    assert result[:real_pot] < result[:nominal_pot]

    # Income should be positive
    assert result[:nominal_monthly_income] > 0
    assert result[:real_monthly_income] > 0
    assert result[:real_monthly_income] < result[:nominal_monthly_income]
  end

  test "zero inflation: real values equal nominal values" do
    result = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_inflation_rate: 0)).call

    assert result[:valid]
    assert_in_delta result[:nominal_pot], result[:real_pot], 0.01
    assert_in_delta result[:nominal_monthly_income], result[:real_monthly_income], 0.01
  end

  test "zero return rate: pot equals total contributions" do
    result = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_return_rate: 0, annual_inflation_rate: 0)).call

    assert result[:valid]
    expected = 50_000 + 500 * 420
    assert_in_delta expected, result[:nominal_pot], 0.01

    # Zero return means annuity payment = pot / months
    expected_income = expected / (25 * 12).to_f
    assert_in_delta expected_income, result[:nominal_monthly_income], 0.01
  end

  test "high inflation significantly reduces real pot" do
    low_inflation = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_inflation_rate: 1)).call
    high_inflation = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_inflation_rate: 5)).call

    # Same nominal pot, different real pot
    assert_in_delta low_inflation[:nominal_pot], high_inflation[:nominal_pot], 0.01
    assert high_inflation[:real_pot] < low_inflation[:real_pot]
  end

  test "inflation correctly discounts by (1+i)^years" do
    result = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_inflation_rate: 3)).call
    years = 35
    expected_real_pot = result[:nominal_pot] / (1.03**years)
    assert_in_delta expected_real_pot, result[:real_pot], 0.01
  end

  # --- Validation errors ---

  test "negative current age returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(current_age: -5))
    calc.call
    assert_includes calc.errors, "Current age must be positive"
  end

  test "retirement age equal to current age returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(current_age: 65, retirement_age: 65))
    calc.call
    assert_includes calc.errors, "Retirement age must be greater than current age"
  end

  test "negative current savings returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(current_savings: -10_000))
    calc.call
    assert_includes calc.errors, "Current savings cannot be negative"
  end

  test "negative monthly contribution returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(monthly_contribution: -500))
    calc.call
    assert_includes calc.errors, "Monthly contribution cannot be negative"
  end

  test "negative return rate returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_return_rate: -2))
    calc.call
    assert_includes calc.errors, "Annual return rate cannot be negative"
  end

  test "negative inflation rate returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(annual_inflation_rate: -1))
    calc.call
    assert_includes calc.errors, "Inflation rate cannot be negative"
  end

  test "zero years in retirement returns error" do
    calc = Finance::PensionCalculator.new(**DEFAULTS.merge(years_in_retirement: 0))
    calc.call
    assert_includes calc.errors, "Years in retirement must be positive"
  end

  # --- Edge cases ---

  test "large contributions and high return produce substantial pot" do
    result = Finance::PensionCalculator.new(
      current_age: 25, retirement_age: 65,
      current_savings: 100_000, monthly_contribution: 2_000,
      annual_return_rate: 8, annual_inflation_rate: 2.5, years_in_retirement: 30
    ).call

    assert result[:valid]
    assert result[:nominal_pot] > 1_000_000
  end

  test "string inputs are coerced" do
    result = Finance::PensionCalculator.new(
      current_age: "30", retirement_age: "65",
      current_savings: "50000", monthly_contribution: "500",
      annual_return_rate: "7", annual_inflation_rate: "2.5",
      years_in_retirement: "25"
    ).call

    assert result[:valid]
    assert result[:nominal_pot] > 0
  end

  test "multiple validation errors returned at once" do
    calc = Finance::PensionCalculator.new(
      current_age: -1, retirement_age: -5, current_savings: -1,
      monthly_contribution: -1, annual_return_rate: -1,
      annual_inflation_rate: -1, years_in_retirement: 0
    )
    calc.call
    assert calc.errors.size >= 5
  end
end
