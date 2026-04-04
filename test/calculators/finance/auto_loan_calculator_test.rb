require "test_helper"

class Finance::AutoLoanCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: standard auto loan with all inputs" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 35_000,
      down_payment: 5_000,
      trade_in_value: 3_000,
      sales_tax_rate: 6.25,
      annual_rate: 6.5,
      term_months: 60
    )
    result = calc.call

    assert result[:valid]
    assert_empty calc.errors

    # Taxable: 35000 - 3000 = 32000; Tax: 32000 * 0.0625 = 2000
    assert_in_delta 2_000.00, result[:sales_tax], 0.01

    # Loan: 35000 + 2000 - 5000 - 3000 = 29000
    assert_in_delta 29_000.00, result[:loan_amount], 0.01

    # Monthly payment for 29000 at 6.5% for 60 months
    assert result[:monthly_payment] > 0
    assert result[:total_interest] > 0
    assert result[:total_cost] > 35_000
    assert_equal 60, result[:term_months]
  end

  test "happy path: no down payment or trade-in" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 25_000,
      down_payment: 0,
      trade_in_value: 0,
      sales_tax_rate: 7,
      annual_rate: 5,
      term_months: 48
    )
    result = calc.call

    assert result[:valid]
    # Tax: 25000 * 0.07 = 1750; Loan: 25000 + 1750 = 26750
    assert_in_delta 1_750.00, result[:sales_tax], 0.01
    assert_in_delta 26_750.00, result[:loan_amount], 0.01
  end

  # --- Zero interest rate ---

  test "zero interest rate divides evenly" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 24_000,
      down_payment: 0,
      trade_in_value: 0,
      sales_tax_rate: 0,
      annual_rate: 0,
      term_months: 24
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.00, result[:monthly_payment], 0.01
    assert_in_delta 0.00, result[:total_interest], 0.01
  end

  # --- Zero sales tax ---

  test "zero sales tax rate" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000,
      down_payment: 5_000,
      trade_in_value: 0,
      sales_tax_rate: 0,
      annual_rate: 5,
      term_months: 60
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.00, result[:sales_tax], 0.01
    assert_in_delta 25_000.00, result[:loan_amount], 0.01
  end

  # --- Validation: negative vehicle price ---

  test "negative vehicle price returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: -10_000, down_payment: 0, trade_in_value: 0,
      sales_tax_rate: 0, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Vehicle price must be positive"
  end

  # --- Validation: zero vehicle price ---

  test "zero vehicle price returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 0, down_payment: 0, trade_in_value: 0,
      sales_tax_rate: 0, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Vehicle price must be positive"
  end

  # --- Validation: negative down payment ---

  test "negative down payment returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000, down_payment: -1_000, trade_in_value: 0,
      sales_tax_rate: 0, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment cannot be negative"
  end

  # --- Validation: negative trade-in ---

  test "negative trade-in value returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000, down_payment: 0, trade_in_value: -5_000,
      sales_tax_rate: 0, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Trade-in value cannot be negative"
  end

  # --- Validation: negative interest rate ---

  test "negative interest rate returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000, down_payment: 0, trade_in_value: 0,
      sales_tax_rate: 0, annual_rate: -5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  # --- Validation: negative sales tax rate ---

  test "negative sales tax rate returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000, down_payment: 0, trade_in_value: 0,
      sales_tax_rate: -5, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Sales tax rate cannot be negative"
  end

  # --- Validation: zero term ---

  test "zero term months returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 30_000, down_payment: 0, trade_in_value: 0,
      sales_tax_rate: 0, annual_rate: 5, term_months: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan term must be positive"
  end

  # --- Validation: down payment + trade-in exceeds price ---

  test "down payment and trade-in exceeding price returns error" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 20_000, down_payment: 15_000, trade_in_value: 10_000,
      sales_tax_rate: 0, annual_rate: 5, term_months: 60
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Down payment and trade-in cannot exceed vehicle price"
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 0, down_payment: -1, trade_in_value: -1,
      sales_tax_rate: -1, annual_rate: -1, term_months: 0
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 5
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: "35000", down_payment: "5000", trade_in_value: "3000",
      sales_tax_rate: "6.25", annual_rate: "6.5", term_months: "60"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  # --- Very large vehicle price ---

  test "very large vehicle price still computes" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 500_000, down_payment: 100_000, trade_in_value: 50_000,
      sales_tax_rate: 10, annual_rate: 8, term_months: 84
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:total_interest] > 0
  end

  # --- Short term ---

  test "24-month term computes correctly" do
    calc = Finance::AutoLoanCalculator.new(
      vehicle_price: 20_000, down_payment: 4_000, trade_in_value: 0,
      sales_tax_rate: 5, annual_rate: 4, term_months: 24
    )
    result = calc.call

    assert result[:valid]
    assert_equal 24, result[:term_months]
    # Loan: 20000 + (20000*0.05) - 4000 = 17000
    assert_in_delta 17_000.00, result[:loan_amount], 0.01
  end
end
