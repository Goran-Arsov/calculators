require "test_helper"

class Finance::SalaryCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: annual salary ---

  test "happy path: annual salary of 52000 at 40 hours per week" do
    calc = Finance::SalaryCalculator.new(amount: 52_000, type: "annual")
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors

    # hourly = 52000 / (52 * 40) = 25.00
    assert_in_delta 25.00, result[:hourly], 0.01
    # daily = 25 * 40 / 5 = 200.00
    assert_in_delta 200.00, result[:daily], 0.01
    # weekly = 25 * 40 = 1000.00
    assert_in_delta 1_000.00, result[:weekly], 0.01
    # biweekly = 25 * 40 * 2 = 2000.00
    assert_in_delta 2_000.00, result[:biweekly], 0.01
    # monthly = 25 * 40 * 52 / 12 = 4333.33
    assert_in_delta 4_333.33, result[:monthly], 0.01
    # annual = 25 * 40 * 52 = 52000.00
    assert_in_delta 52_000.00, result[:annual], 0.01
  end

  # --- Happy path: hourly rate ---

  test "happy path: hourly rate of 30 at 40 hours per week" do
    calc = Finance::SalaryCalculator.new(amount: 30, type: "hourly")
    result = calc.call

    assert result[:valid]
    assert_in_delta 30.00, result[:hourly], 0.01
    assert_in_delta 240.00, result[:daily], 0.01
    assert_in_delta 1_200.00, result[:weekly], 0.01
    assert_in_delta 2_400.00, result[:biweekly], 0.01
    assert_in_delta 5_200.00, result[:monthly], 0.01
    assert_in_delta 62_400.00, result[:annual], 0.01
  end

  # --- Happy path: monthly salary ---

  test "happy path: monthly salary of 5000" do
    calc = Finance::SalaryCalculator.new(amount: 5_000, type: "monthly")
    result = calc.call

    assert result[:valid]
    # hourly = 5000 * 12 / (52 * 40) = 28.846...
    assert_in_delta 28.85, result[:hourly], 0.01
    assert_in_delta 60_000.00, result[:annual], 0.01
  end

  # --- Happy path: weekly salary ---

  test "happy path: weekly salary of 1500" do
    calc = Finance::SalaryCalculator.new(amount: 1_500, type: "weekly")
    result = calc.call

    assert result[:valid]
    # hourly = 1500 / 40 = 37.50
    assert_in_delta 37.50, result[:hourly], 0.01
    assert_in_delta 78_000.00, result[:annual], 0.01
  end

  # --- Happy path: daily salary ---

  test "happy path: daily salary of 300" do
    calc = Finance::SalaryCalculator.new(amount: 300, type: "daily")
    result = calc.call

    assert result[:valid]
    # hourly = 300 / (40/5) = 300 / 8 = 37.50
    assert_in_delta 37.50, result[:hourly], 0.01
    assert_in_delta 300.00, result[:daily], 0.01
  end

  # --- Happy path: biweekly salary ---

  test "happy path: biweekly salary of 3000" do
    calc = Finance::SalaryCalculator.new(amount: 3_000, type: "biweekly")
    result = calc.call

    assert result[:valid]
    # hourly = 3000 / (40 * 2) = 37.50
    assert_in_delta 37.50, result[:hourly], 0.01
    assert_in_delta 78_000.00, result[:annual], 0.01
  end

  # --- Custom hours per week ---

  test "custom hours per week: 20 hours" do
    calc = Finance::SalaryCalculator.new(amount: 40_000, type: "annual", hours_per_week: 20)
    result = calc.call

    assert result[:valid]
    # hourly = 40000 / (52 * 20) = 38.46
    assert_in_delta 38.46, result[:hourly], 0.01
    # daily = 38.46 * 20 / 5 = 153.85
    assert_in_delta 153.85, result[:daily], 0.01
    # weekly = 38.46 * 20 = 769.23
    assert_in_delta 769.23, result[:weekly], 0.01
  end

  # --- Negative values ---

  test "negative amount returns error" do
    calc = Finance::SalaryCalculator.new(amount: -50_000, type: "annual")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "negative hours per week returns error" do
    calc = Finance::SalaryCalculator.new(amount: 50_000, type: "annual", hours_per_week: -40)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hours per week must be positive"
  end

  # --- Zero values ---

  test "zero amount returns error" do
    calc = Finance::SalaryCalculator.new(amount: 0, type: "annual")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
  end

  test "zero hours per week returns error" do
    calc = Finance::SalaryCalculator.new(amount: 50_000, type: "annual", hours_per_week: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Hours per week must be positive"
  end

  # --- Invalid type ---

  test "invalid salary type returns error" do
    calc = Finance::SalaryCalculator.new(amount: 50_000, type: "quarterly")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid salary type"
  end

  test "empty salary type returns error" do
    calc = Finance::SalaryCalculator.new(amount: 50_000, type: "")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid salary type"
  end

  # --- Large numbers ---

  test "very large annual salary still computes" do
    calc = Finance::SalaryCalculator.new(amount: 100_000_000, type: "annual")
    result = calc.call

    assert result[:valid]
    assert result[:hourly] > 0
    assert_in_delta 100_000_000.00, result[:annual], 0.01
  end

  test "very large hourly rate still computes" do
    calc = Finance::SalaryCalculator.new(amount: 10_000, type: "hourly")
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.00, result[:hourly], 0.01
    assert result[:annual] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::SalaryCalculator.new(amount: 0, type: "invalid", hours_per_week: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Amount must be positive"
    assert_includes calc.errors, "Hours per week must be positive"
    assert_includes calc.errors, "Invalid salary type"
    assert_equal 3, calc.errors.size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::SalaryCalculator.new(amount: "52000", type: "annual", hours_per_week: "40")
    result = calc.call

    assert result[:valid]
    assert_in_delta 25.00, result[:hourly], 0.01
  end

  # --- Edge case: consistency across all types ---

  test "all output breakdowns are consistent from hourly base" do
    calc = Finance::SalaryCalculator.new(amount: 50, type: "hourly", hours_per_week: 40)
    result = calc.call

    assert result[:valid]
    hourly = result[:hourly]
    assert_in_delta hourly * 40 / 5.0, result[:daily], 0.01
    assert_in_delta hourly * 40, result[:weekly], 0.01
    assert_in_delta hourly * 40 * 2, result[:biweekly], 0.01
    assert_in_delta hourly * 40 * 52 / 12.0, result[:monthly], 0.01
    assert_in_delta hourly * 40 * 52, result[:annual], 0.01
  end

  # --- Edge case: high hours per week ---

  test "high hours per week like 60" do
    calc = Finance::SalaryCalculator.new(amount: 120_000, type: "annual", hours_per_week: 60)
    result = calc.call

    assert result[:valid]
    # hourly = 120000 / (52 * 60) = 38.46
    assert_in_delta 38.46, result[:hourly], 0.01
    # daily = 38.46 * 60 / 5 = 461.54
    assert_in_delta 461.54, result[:daily], 0.01
  end
end
