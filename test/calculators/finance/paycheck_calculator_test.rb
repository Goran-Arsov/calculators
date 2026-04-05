require "test_helper"

class Finance::PaycheckCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: $75,000 salary with medium state tax, biweekly" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 75_000, state_tax_level: "medium", pay_frequency: "biweekly")
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors
    assert_equal 75_000.0, result[:annual_gross]
    assert result[:annual_net] > 0
    assert result[:annual_net] < 75_000
    assert_equal 26, result[:pay_periods]
    assert_in_delta 75_000.0 / 26, result[:per_paycheck_gross], 0.01
    assert result[:per_paycheck_net] > 0
    assert result[:federal_tax] > 0
    assert result[:state_tax] > 0
    assert result[:fica] > 0
  end

  test "happy path: $150,000 salary with high state tax, monthly" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 150_000, state_tax_level: "high", pay_frequency: "monthly")
    result = calc.call

    assert result[:valid]
    assert_equal 12, result[:pay_periods]
    assert result[:federal_tax] > result[:state_tax]
    assert result[:social_security] > 0
    assert result[:medicare] > 0
  end

  test "happy path: salary with pre-tax deductions" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 100_000, pre_tax_deductions: 20_000)
    result = calc.call

    assert result[:valid]
    assert_equal 20_000.0, result[:pre_tax_deductions]
    # Pre-tax deductions reduce federal and state tax
    calc_no_deductions = Finance::PaycheckCalculator.new(annual_salary: 100_000, pre_tax_deductions: 0)
    result_no_deductions = calc_no_deductions.call
    assert result[:federal_tax] < result_no_deductions[:federal_tax]
  end

  # --- Zero / Negative values ---

  test "zero salary returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual salary must be positive"
  end

  test "negative salary returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: -50_000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual salary must be positive"
  end

  test "negative pre-tax deductions returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 75_000, pre_tax_deductions: -1000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Pre-tax deductions cannot be negative"
  end

  test "pre-tax deductions exceeding salary returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 50_000, pre_tax_deductions: 60_000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Pre-tax deductions cannot exceed salary"
  end

  # --- Invalid options ---

  test "invalid state tax level returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 75_000, state_tax_level: "invalid")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid state tax level"
  end

  test "invalid pay frequency returns error" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 75_000, pay_frequency: "daily")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid pay frequency"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::PaycheckCalculator.new(annual_salary: "80000", pre_tax_deductions: "5000")
    result = calc.call

    assert result[:valid]
    assert_equal 80_000.0, result[:annual_gross]
    assert result[:per_paycheck_net] > 0
  end

  # --- Pay frequency variations ---

  test "weekly pay frequency gives 52 periods" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 52_000, pay_frequency: "weekly")
    result = calc.call

    assert result[:valid]
    assert_equal 52, result[:pay_periods]
    assert_in_delta 1_000.0, result[:per_paycheck_gross], 0.01
  end

  test "semimonthly pay frequency gives 24 periods" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 72_000, pay_frequency: "semimonthly")
    result = calc.call

    assert result[:valid]
    assert_equal 24, result[:pay_periods]
    assert_in_delta 3_000.0, result[:per_paycheck_gross], 0.01
  end

  # --- No state tax ---

  test "no state tax states compute zero state tax" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 100_000, state_tax_level: "none")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:state_tax], 0.01
  end

  # --- Large numbers ---

  test "very large salary still computes" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 5_000_000)
    result = calc.call

    assert result[:valid]
    assert result[:federal_tax] > 0
    assert result[:annual_net] > 0
    # Social Security capped at wage base
    assert_in_delta 168_600 * 0.062, result[:social_security], 0.01
  end

  # --- Medicare surtax ---

  test "high income triggers Medicare surtax" do
    calc = Finance::PaycheckCalculator.new(annual_salary: 300_000, state_tax_level: "none", pre_tax_deductions: 0)
    result = calc.call

    assert result[:valid]
    base_medicare = 300_000 * 0.0145
    surtax = (300_000 - 200_000) * 0.009
    assert_in_delta base_medicare + surtax, result[:medicare], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::PaycheckCalculator.new(annual_salary: -1, pre_tax_deductions: -1, state_tax_level: "bogus", pay_frequency: "hourly")
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end
end
