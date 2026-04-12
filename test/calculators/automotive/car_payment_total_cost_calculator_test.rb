require "test_helper"

class Automotive::CarPaymentTotalCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard vehicle with all costs" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 35_000, down_payment: 5_000,
      loan_rate: 6.5, loan_term_months: 60,
      annual_insurance: 1_800, monthly_fuel: 150,
      annual_maintenance: 800, annual_registration: 250,
      sales_tax_rate: 6.25, ownership_years: 5
    ).call
    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:total_interest] > 0
    assert result[:total_cost_of_ownership] > 35_000
    assert result[:monthly_cost_of_ownership] > 0
    assert_equal 5, result[:ownership_years]
  end

  # --- Zero interest rate ---

  test "zero interest rate divides loan evenly" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 24_000, down_payment: 0,
      loan_rate: 0, loan_term_months: 24,
      annual_insurance: 1_200, monthly_fuel: 100,
      annual_maintenance: 600, ownership_years: 2
    ).call
    assert result[:valid]
    assert_in_delta 1_000.0, result[:monthly_payment], 0.01
    assert_in_delta 0.0, result[:total_interest], 0.01
  end

  # --- All costs add up ---

  test "total cost includes all components" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 30_000, down_payment: 5_000,
      loan_rate: 0, loan_term_months: 60,
      annual_insurance: 1_000, monthly_fuel: 100,
      annual_maintenance: 500, annual_registration: 200,
      sales_tax_rate: 0, ownership_years: 5
    ).call
    assert result[:valid]
    expected_total = 5_000 + 25_000 + 5_000 + 6_000 + 2_500 + 1_000
    assert_in_delta expected_total, result[:total_cost_of_ownership], 1.0
  end

  # --- Validation errors ---

  test "zero vehicle price returns error" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 0, down_payment: 0,
      loan_rate: 5, loan_term_months: 60,
      annual_insurance: 1_200, monthly_fuel: 100,
      annual_maintenance: 600
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Vehicle price must be positive"
  end

  test "negative down payment returns error" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 30_000, down_payment: -1_000,
      loan_rate: 5, loan_term_months: 60,
      annual_insurance: 1_200, monthly_fuel: 100,
      annual_maintenance: 600
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Down payment cannot be negative"
  end

  test "down payment exceeding price returns error" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 30_000, down_payment: 35_000,
      loan_rate: 5, loan_term_months: 60,
      annual_insurance: 1_200, monthly_fuel: 100,
      annual_maintenance: 600
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Down payment cannot exceed vehicle price"
  end

  test "zero loan term returns error" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: 30_000, down_payment: 5_000,
      loan_rate: 5, loan_term_months: 0,
      annual_insurance: 1_200, monthly_fuel: 100,
      annual_maintenance: 600
    ).call
    refute result[:valid]
    assert_includes result[:errors], "Loan term must be positive"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    result = Automotive::CarPaymentTotalCostCalculator.new(
      vehicle_price: "35000", down_payment: "5000",
      loan_rate: "6.5", loan_term_months: "60",
      annual_insurance: "1800", monthly_fuel: "150",
      annual_maintenance: "800"
    ).call
    assert result[:valid]
  end
end
