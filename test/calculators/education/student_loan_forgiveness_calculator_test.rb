require "test_helper"

class Education::StudentLoanForgivenessCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: PSLF ---

  test "PSLF calculates forgiveness after 120 payments" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "pslf"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert result[:forgiven_amount] >= 0
    assert_equal 120, result[:remaining_payments]
    assert_equal 0.0, result[:tax_on_forgiveness]
    assert_equal "pslf", result[:program]
  end

  test "PSLF with payments already made reduces remaining payments" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "pslf", payments_made: 60
    )
    result = calc.call

    assert result[:valid]
    assert_equal 60, result[:remaining_payments]
  end

  # --- IDR 20-year ---

  test "IDR 20-year forgiveness calculates correctly" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 80_000, annual_rate: 6.5, monthly_income: 3_500, program: "idr_20"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
    assert_equal 240, result[:remaining_payments]
    assert result[:forgiven_amount] > 0
    assert result[:tax_on_forgiveness] > 0
  end

  # --- IDR 25-year ---

  test "IDR 25-year forgiveness calculates correctly" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 100_000, annual_rate: 7.0, monthly_income: 4_000, program: "idr_25"
    )
    result = calc.call

    assert result[:valid]
    assert_equal 300, result[:remaining_payments]
    assert result[:total_with_standard] > 0
  end

  # --- Family size affects payment ---

  test "larger family size reduces monthly payment" do
    small_family = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "pslf", family_size: 1
    )
    large_family = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "pslf", family_size: 4
    )

    assert large_family.call[:monthly_payment] < small_family.call[:monthly_payment]
  end

  # --- Savings calculation ---

  test "savings reflects difference from standard plan" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "pslf"
    )
    result = calc.call

    assert result[:valid]
    assert result[:savings] >= 0
    assert result[:total_with_standard] > 0
  end

  # --- Validation errors ---

  test "zero loan balance returns error" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 0, annual_rate: 6.0, monthly_income: 4_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Loan balance must be positive"
  end

  test "negative interest rate returns error" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: -2, monthly_income: 4_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Interest rate cannot be negative"
  end

  test "zero income returns error" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly income must be positive"
  end

  test "invalid program returns error" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, program: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid forgiveness program"
  end

  test "negative payments_made returns error" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 50_000, annual_rate: 6.0, monthly_income: 4_000, payments_made: -5
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Payments made cannot be negative"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: "50000", annual_rate: "6", monthly_income: "4000"
    )
    result = calc.call

    assert result[:valid]
    assert result[:monthly_payment] > 0
  end

  # --- Large balance ---

  test "very large balance still computes" do
    calc = Education::StudentLoanForgivenessCalculator.new(
      loan_balance: 300_000, annual_rate: 7.0, monthly_income: 5_000, program: "pslf"
    )
    result = calc.call

    assert result[:valid]
    assert result[:forgiven_amount] > 0
  end
end
