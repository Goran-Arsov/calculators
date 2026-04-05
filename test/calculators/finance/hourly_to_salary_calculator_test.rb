require "test_helper"

class Finance::HourlyToSalaryCalculatorTest < ActiveSupport::TestCase
  # --- Hourly to salary ---

  test "standard $25/hr to annual salary" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 25, direction: "hourly_to_salary"
    ).call

    assert result[:valid]
    assert_in_delta 25.00, result[:hourly], 0.01
    assert_in_delta 200.00, result[:daily], 0.01
    assert_in_delta 1000.00, result[:weekly], 0.01
    assert_in_delta 2000.00, result[:biweekly], 0.01
    assert_in_delta 4333.33, result[:monthly], 0.01
    assert_in_delta 52000.00, result[:annual], 0.01
  end

  test "$50/hr at 30 hours per week" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 50, direction: "hourly_to_salary", hours_per_week: 30
    ).call

    assert result[:valid]
    assert_in_delta 78000.00, result[:annual], 0.01
    assert_in_delta 300.00, result[:daily], 0.01
  end

  # --- Salary to hourly ---

  test "annual salary of $52000 to hourly" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 52000, direction: "salary_to_hourly"
    ).call

    assert result[:valid]
    assert_in_delta 25.00, result[:hourly], 0.01
    assert_in_delta 52000.00, result[:annual], 0.01
  end

  test "annual salary of $100000 at 50 hours per week" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 100000, direction: "salary_to_hourly", hours_per_week: 50
    ).call

    assert result[:valid]
    # 100000 / (50 * 52) = 38.46
    assert_in_delta 38.46, result[:hourly], 0.01
  end

  # --- Custom weeks per year ---

  test "48 weeks per year increases hourly rate" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 52000, direction: "salary_to_hourly", weeks_per_year: 48
    ).call

    assert result[:valid]
    # 52000 / (40 * 48) = 27.08
    assert_in_delta 27.08, result[:hourly], 0.01
  end

  # --- Round trip consistency ---

  test "hourly to salary and back is consistent" do
    forward = Finance::HourlyToSalaryCalculator.new(
      amount: 30, direction: "hourly_to_salary"
    ).call

    reverse = Finance::HourlyToSalaryCalculator.new(
      amount: forward[:annual], direction: "salary_to_hourly"
    ).call

    assert_in_delta 30.00, reverse[:hourly], 0.01
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: "25", direction: "hourly_to_salary", hours_per_week: "40", weeks_per_year: "52"
    ).call

    assert result[:valid]
    assert_in_delta 52000.00, result[:annual], 0.01
  end

  # --- Validation errors ---

  test "error when amount is zero" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 0, direction: "hourly_to_salary"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Amount must be positive"
  end

  test "error when direction is invalid" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 25, direction: "invalid"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid direction"
  end

  test "error when hours per week is zero" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 25, direction: "hourly_to_salary", hours_per_week: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hours per week must be positive"
  end

  test "error when weeks per year is zero" do
    result = Finance::HourlyToSalaryCalculator.new(
      amount: 25, direction: "hourly_to_salary", weeks_per_year: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Weeks per year must be positive"
  end
end
