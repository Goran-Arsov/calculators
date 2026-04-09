require "test_helper"

class Finance::CapitalGainsTaxCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: long-term ---

  test "long-term gain at 15% rate for single filer" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.0, result[:capital_gain], 0.01
    assert result[:is_long_term]
    assert_in_delta 15.0, result[:tax_rate], 0.01
    assert_in_delta 1_500.0, result[:tax_owed], 0.01
  end

  test "long-term gain at 0% rate for low income single" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 5_000, sale_price: 10_000,
      holding_period_months: 24, annual_income: 30_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert result[:is_long_term]
    assert_in_delta 0.0, result[:tax_rate], 0.01
    assert_in_delta 0.0, result[:tax_owed], 0.01
  end

  test "long-term gain at 20% rate for high income single" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 100_000, sale_price: 200_000,
      holding_period_months: 36, annual_income: 500_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert result[:is_long_term]
    assert_in_delta 20.0, result[:tax_rate], 0.01
    assert_in_delta 20_000.0, result[:tax_owed], 0.01
  end

  # --- Happy path: short-term ---

  test "short-term gain taxed at ordinary income rates" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 15_000,
      holding_period_months: 6, annual_income: 50_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 5_000.0, result[:capital_gain], 0.01
    refute result[:is_long_term]
    assert result[:tax_owed] > 0
  end

  test "exactly 12 months is short-term" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 15_000,
      holding_period_months: 12, annual_income: 50_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    refute result[:is_long_term]
  end

  test "13 months is long-term" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 15_000,
      holding_period_months: 13, annual_income: 50_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert result[:is_long_term]
  end

  # --- NIIT ---

  test "NIIT applies for single filer over 200k" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 100_000, sale_price: 200_000,
      holding_period_months: 24, annual_income: 250_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert result[:niit_owed] > 0
    # Total income = 250000 + 100000 = 350000, over 200000 threshold
    # Excess = 150000, gain = 100000, NIIT base = min(100000, 150000) = 100000
    assert_in_delta 3_800.0, result[:niit_owed], 0.01
  end

  test "NIIT does not apply below threshold" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 15_000,
      holding_period_months: 24, annual_income: 150_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:niit_owed], 0.01
  end

  test "NIIT for married jointly over 250k" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 100_000, sale_price: 300_000,
      holding_period_months: 24, annual_income: 200_000,
      filing_status: "married_jointly"
    )
    result = calc.call

    assert result[:valid]
    # Total income = 200000 + 200000 = 400000, over 250000
    # Excess = 150000, gain = 200000, NIIT base = min(200000, 150000) = 150000
    assert_in_delta 5_700.0, result[:niit_owed], 0.01
  end

  # --- Capital loss ---

  test "capital loss results in zero tax" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 20_000, sale_price: 15_000,
      holding_period_months: 24, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta(-5_000.0, result[:capital_gain], 0.01)
    assert_in_delta 0.0, result[:tax_owed], 0.01
    assert_in_delta 0.0, result[:niit_owed], 0.01
    assert_in_delta(-5_000.0, result[:net_profit], 0.01)
    assert_in_delta 0.0, result[:effective_rate], 0.01
  end

  # --- Filing statuses ---

  test "married jointly filing status works" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "married_jointly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:is_long_term]
    # 80000 + 10000 = 90000, under 94050 threshold for 0%
    assert_in_delta 0.0, result[:tax_rate], 0.01
  end

  test "head of household filing status works" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 50_000,
      filing_status: "head_of_household"
    )
    result = calc.call

    assert result[:valid]
    assert result[:is_long_term]
  end

  test "invalid filing status returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid filing status"
  end

  # --- Negative values ---

  test "negative purchase price returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: -10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Purchase price must be positive"
  end

  test "negative sale price returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: -5_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Sale price must be positive"
  end

  test "negative holding period returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: -6, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Holding period must be positive"
  end

  test "negative annual income returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: -50_000,
      filing_status: "single"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Annual income cannot be negative"
  end

  # --- Zero values ---

  test "zero purchase price returns error" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 0, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Purchase price must be positive"
  end

  test "zero annual income is valid" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 0,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    # 0 + 10000 = 10000 < 47025, so 0% long-term rate
    assert_in_delta 0.0, result[:tax_rate], 0.01
  end

  # --- Large numbers ---

  test "very large gain computes correctly" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 500_000, sale_price: 2_000_000,
      holding_period_months: 36, annual_income: 300_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_500_000.0, result[:capital_gain], 0.01
    assert result[:tax_owed] > 0
    assert result[:niit_owed] > 0
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: -1, sale_price: -1,
      holding_period_months: -1, annual_income: -1,
      filing_status: "invalid"
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: "10000", sale_price: "20000",
      holding_period_months: "18", annual_income: "80000",
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 10_000.0, result[:capital_gain], 0.01
  end

  # --- Effective rate ---

  test "effective rate includes NIIT" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 100_000, sale_price: 200_000,
      holding_period_months: 24, annual_income: 300_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    total_tax = result[:tax_owed] + result[:niit_owed]
    expected_effective = total_tax / result[:capital_gain] * 100
    assert_in_delta expected_effective, result[:effective_rate], 0.01
  end

  # --- Net profit ---

  test "net profit equals gain minus all taxes" do
    calc = Finance::CapitalGainsTaxCalculator.new(
      purchase_price: 10_000, sale_price: 20_000,
      holding_period_months: 18, annual_income: 80_000,
      filing_status: "single"
    )
    result = calc.call

    assert result[:valid]
    expected_net = result[:capital_gain] - result[:tax_owed] - result[:niit_owed]
    assert_in_delta expected_net, result[:net_profit], 0.01
  end
end
