require "test_helper"

class Finance::SideHustleCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: basic side hustle calculation" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: 10_000, tax_rate_percent: 22, hours_per_week: 20
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 40_000.0, result[:net_profit], 0.01

    # SE tax: 40000 * 0.9235 * 0.153
    expected_se_tax = 40_000 * 0.9235 * 0.153
    assert_in_delta expected_se_tax, result[:self_employment_tax], 0.01

    # Income tax: 40000 * 0.22
    expected_income_tax = 40_000 * 0.22
    assert_in_delta expected_income_tax, result[:income_tax_estimate], 0.01

    expected_take_home = 40_000 - expected_se_tax - expected_income_tax
    assert_in_delta expected_take_home, result[:annual_take_home], 0.01

    expected_monthly = expected_take_home / 12.0
    assert_in_delta expected_monthly, result[:monthly_take_home], 0.01

    annual_hours = 20 * 52
    expected_hourly = expected_take_home / annual_hours
    assert_in_delta expected_hourly, result[:effective_hourly_rate], 0.01
  end

  test "happy path: zero expenses" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 30_000, business_expenses: 0, tax_rate_percent: 15, hours_per_week: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 30_000.0, result[:net_profit], 0.01
    assert result[:annual_take_home] > 0
  end

  test "happy path: zero revenue with zero expenses" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 0, business_expenses: 0, tax_rate_percent: 22, hours_per_week: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:net_profit], 0.01
    assert_in_delta 0.0, result[:self_employment_tax], 0.01
    assert_in_delta 0.0, result[:annual_take_home], 0.01
  end

  test "happy path: expenses exceed revenue produces negative take home" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 10_000, business_expenses: 15_000, tax_rate_percent: 22, hours_per_week: 10
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta(-5_000.0, result[:net_profit], 0.01)
    # SE tax and income tax are zero when net is negative (clamped at 0)
    assert_in_delta 0.0, result[:self_employment_tax], 0.01
    assert_in_delta 0.0, result[:income_tax_estimate], 0.01
  end

  test "happy path: zero tax rate" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: 10_000, tax_rate_percent: 0, hours_per_week: 20
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:income_tax_estimate], 0.01
    # Take home = net - SE tax only
    expected_se_tax = 40_000 * 0.9235 * 0.153
    assert_in_delta(40_000 - expected_se_tax, result[:annual_take_home], 0.01)
  end

  # --- Validation errors ---

  test "negative gross revenue returns error" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: -1, business_expenses: 0, tax_rate_percent: 22, hours_per_week: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Gross revenue cannot be negative"
  end

  test "negative business expenses returns error" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: -1, tax_rate_percent: 22, hours_per_week: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Business expenses cannot be negative"
  end

  test "tax rate over 100 returns error" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: 0, tax_rate_percent: 101, hours_per_week: 10
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Tax rate must be between 0 and 100"
  end

  test "zero hours per week returns error" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: 0, tax_rate_percent: 22, hours_per_week: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hours per week must be positive"
  end

  test "hours per week over 168 returns error" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 50_000, business_expenses: 0, tax_rate_percent: 22, hours_per_week: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hours per week cannot exceed 168"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: "50000", business_expenses: "10000", tax_rate_percent: "22", hours_per_week: "20"
    )
    result = calc.call

    assert result[:valid]
    assert result[:annual_take_home] > 0
  end

  # --- Large numbers ---

  test "very large revenue still computes" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: 10_000_000, business_expenses: 1_000_000, tax_rate_percent: 37, hours_per_week: 40
    )
    result = calc.call

    assert result[:valid]
    assert result[:annual_take_home] > 0
    assert result[:effective_hourly_rate] > 0
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::SideHustleCalculator.new(
      gross_revenue: -1, business_expenses: -1, tax_rate_percent: 200, hours_per_week: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end
end
