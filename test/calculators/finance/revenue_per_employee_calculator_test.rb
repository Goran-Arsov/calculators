require "test_helper"

class Finance::RevenuePerEmployeeCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic: revenue=1200000, employees=10 -> $120000/employee" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 1_200_000, employees: 10).call
    assert result[:valid]
    assert_equal 120_000.0, result[:revenue_per_employee]
    assert_equal 10_000.0, result[:revenue_per_employee_monthly]
    assert_equal 30_000.0, result[:revenue_per_employee_quarterly]
  end

  test "revenue per employee with net income calculates profit per employee" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 1_200_000, employees: 10, net_income: 300_000).call
    assert result[:valid]
    assert_equal 120_000.0, result[:revenue_per_employee]
    assert_equal 30_000.0, result[:profit_per_employee]
  end

  test "single employee" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 500_000, employees: 1).call
    assert result[:valid]
    assert_equal 500_000.0, result[:revenue_per_employee]
    assert_in_delta 41_666.6667, result[:revenue_per_employee_monthly], 0.001
  end

  test "large company: revenue=10B, employees=50000" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 10_000_000_000, employees: 50_000).call
    assert result[:valid]
    assert_equal 200_000.0, result[:revenue_per_employee]
  end

  test "string coercion works for numeric inputs" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: "1200000", employees: "10").call
    assert result[:valid]
    assert_equal 120_000.0, result[:revenue_per_employee]
  end

  # --- Without optional net income ---

  test "result does not include profit per employee without net_income" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 1_200_000, employees: 10).call
    assert result[:valid]
    refute result.key?(:profit_per_employee)
  end

  # --- Validation errors ---

  test "error when revenue is zero" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 0, employees: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Annual revenue must be positive"
  end

  test "error when employees is zero" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 1_200_000, employees: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Number of employees must be positive"
  end

  test "error when revenue is negative" do
    result = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: -100, employees: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Annual revenue must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::RevenuePerEmployeeCalculator.new(annual_revenue: 1_200_000, employees: 10)
    assert_equal [], calc.errors
  end
end
