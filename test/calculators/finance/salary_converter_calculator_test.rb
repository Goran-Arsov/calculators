require "test_helper"

class Finance::SalaryConverterCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: annual salary ---

  test "annual salary of 52000 at 40 hours/week, 52 weeks/year" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 52_000, period: "annual"
    ).call

    assert result[:valid]
    assert_in_delta 25.00, result[:hourly], 0.01
    assert_in_delta 200.00, result[:daily], 0.01
    assert_in_delta 1_000.00, result[:weekly], 0.01
    assert_in_delta 2_000.00, result[:biweekly], 0.01
    assert_in_delta 4_333.33, result[:monthly], 0.01
    assert_in_delta 52_000.00, result[:annual], 0.01
  end

  # --- Happy path: hourly rate ---

  test "hourly rate of 30" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 30, period: "hourly"
    ).call

    assert result[:valid]
    assert_in_delta 30.00, result[:hourly], 0.01
    assert_in_delta 62_400.00, result[:annual], 0.01
  end

  # --- Custom weeks per year ---

  test "48 weeks per year increases hourly rate" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 52_000, period: "annual", weeks_per_year: 48
    ).call

    assert result[:valid]
    # hourly = 52000 / (48 * 40) = 27.08
    assert_in_delta 27.08, result[:hourly], 0.01
    assert_in_delta 52_000.00, result[:annual], 0.01
  end

  # --- Custom hours per week ---

  test "20 hours per week part-time" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 40_000, period: "annual", hours_per_week: 20
    ).call

    assert result[:valid]
    # hourly = 40000 / (52 * 20) = 38.46
    assert_in_delta 38.46, result[:hourly], 0.01
  end

  # --- Different input periods ---

  test "monthly salary conversion" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 5_000, period: "monthly"
    ).call

    assert result[:valid]
    assert_in_delta 60_000.00, result[:annual], 0.01
  end

  test "biweekly salary conversion" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 2_000, period: "biweekly"
    ).call

    assert result[:valid]
    assert_in_delta 25.0, result[:hourly], 0.01
  end

  test "weekly salary conversion" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 1_000, period: "weekly"
    ).call

    assert result[:valid]
    assert_in_delta 25.0, result[:hourly], 0.01
    assert_in_delta 52_000.0, result[:annual], 0.01
  end

  test "daily salary conversion" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 200, period: "daily"
    ).call

    assert result[:valid]
    assert_in_delta 25.0, result[:hourly], 0.01
  end

  # --- Validation errors ---

  test "error when amount is zero" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 0, period: "annual"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Amount must be positive"
  end

  test "error when period is invalid" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 50_000, period: "quarterly"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid period"
  end

  test "error when hours per week is zero" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 50_000, period: "annual", hours_per_week: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hours per week must be positive"
  end

  test "error when weeks per year is zero" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 50_000, period: "annual", weeks_per_year: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Weeks per year must be positive"
  end

  test "multiple errors at once" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 0, period: "invalid", hours_per_week: 0, weeks_per_year: 0
    ).call

    refute result[:valid]
    assert_equal 4, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Finance::SalaryConverterCalculator.new(
      amount: "52000", period: "annual", hours_per_week: "40", weeks_per_year: "52"
    ).call

    assert result[:valid]
    assert_in_delta 25.00, result[:hourly], 0.01
  end

  # --- Edge case: consistency ---

  test "all breakdowns are consistent from hourly base" do
    result = Finance::SalaryConverterCalculator.new(
      amount: 50, period: "hourly", hours_per_week: 40, weeks_per_year: 52
    ).call

    assert result[:valid]
    hourly = result[:hourly]
    assert_in_delta hourly * 40 / 5.0, result[:daily], 0.01
    assert_in_delta hourly * 40, result[:weekly], 0.01
    assert_in_delta hourly * 40 * 2, result[:biweekly], 0.01
    assert_in_delta hourly * 40 * 52 / 12.0, result[:monthly], 0.01
    assert_in_delta hourly * 40 * 52, result[:annual], 0.01
  end
end
