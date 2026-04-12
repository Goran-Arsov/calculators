require "test_helper"

class Finance::FreelanceRateCalculatorTest < ActiveSupport::TestCase
  test "happy path: standard freelance rate" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 15_000,
      billable_hours_per_week: 25, weeks_vacation: 4,
      tax_rate: 30, profit_margin: 10
    )
    result = calc.call

    assert result[:valid]
    assert result[:hourly_rate] > 0
    assert result[:daily_rate] > result[:hourly_rate]
    assert result[:weekly_rate] > result[:daily_rate]
    assert result[:monthly_rate] > 0
    assert_equal 1200, result[:annual_billable_hours]
    assert_equal 48, result[:working_weeks]
  end

  test "no vacation and no profit margin" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: 100_000, annual_expenses: 0,
      billable_hours_per_week: 40, weeks_vacation: 0,
      tax_rate: 0, profit_margin: 0
    )
    result = calc.call

    assert result[:valid]
    expected_hours = 40 * 52
    expected_hourly = 100_000.0 / expected_hours
    assert_in_delta expected_hourly, result[:hourly_rate], 0.01
  end

  test "high tax rate increases rate" do
    low_tax = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 10_000,
      billable_hours_per_week: 30, weeks_vacation: 2,
      tax_rate: 10, profit_margin: 0
    ).call

    high_tax = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 10_000,
      billable_hours_per_week: 30, weeks_vacation: 2,
      tax_rate: 40, profit_margin: 0
    ).call

    assert high_tax[:hourly_rate] > low_tax[:hourly_rate]
  end

  test "negative income returns error" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: -50_000, annual_expenses: 10_000,
      billable_hours_per_week: 25, weeks_vacation: 4,
      tax_rate: 30, profit_margin: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Target annual income must be positive"
  end

  test "zero billable hours returns error" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 10_000,
      billable_hours_per_week: 0, weeks_vacation: 4,
      tax_rate: 30, profit_margin: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Billable hours per week must be positive"
  end

  test "52 weeks vacation returns error" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 10_000,
      billable_hours_per_week: 25, weeks_vacation: 52,
      tax_rate: 30, profit_margin: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Vacation weeks must be between 0 and 51"
  end

  test "tax rate of 100 returns error" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: 80_000, annual_expenses: 10_000,
      billable_hours_per_week: 25, weeks_vacation: 4,
      tax_rate: 100, profit_margin: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Tax rate must be between 0 and 99"
  end

  test "string inputs are coerced" do
    calc = Finance::FreelanceRateCalculator.new(
      target_annual_income: "80000", annual_expenses: "15000",
      billable_hours_per_week: "25", weeks_vacation: "4",
      tax_rate: "30", profit_margin: "10"
    )
    result = calc.call

    assert result[:valid]
    assert result[:hourly_rate] > 0
  end
end
