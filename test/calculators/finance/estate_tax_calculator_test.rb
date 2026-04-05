require "test_helper"

class Finance::EstateTaxCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "happy path: estate below exemption owes no tax" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 5_000_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:estate_tax], 0.01
    assert_in_delta 0.0, result[:taxable_estate], 0.01
    assert_in_delta 5_000_000.0, result[:net_to_heirs], 0.01
    assert_in_delta 13_610_000.0, result[:exemption], 0.01
  end

  test "happy path: estate above single exemption" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 15_000_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    # Taxable: 15M - 13.61M = 1,390,000
    assert_in_delta 1_390_000.0, result[:taxable_estate], 0.01
    assert result[:estate_tax] > 0
    assert result[:effective_rate] > 0
    assert result[:net_to_heirs] < 15_000_000
  end

  test "happy path: married with portability doubles exemption" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 20_000_000, filing_status: "married")
    result = calc.call

    assert result[:valid]
    assert_in_delta 27_220_000.0, result[:exemption], 0.01
    # Estate is below married exemption
    assert_in_delta 0.0, result[:taxable_estate], 0.01
    assert_in_delta 0.0, result[:estate_tax], 0.01
  end

  test "happy path: large estate with deductions" do
    calc = Finance::EstateTaxCalculator.new(
      estate_value: 20_000_000, filing_status: "single", deductions: 1_000_000
    )
    result = calc.call

    assert result[:valid]
    # Taxable: 20M - 1M - 13.61M = 5,390,000
    assert_in_delta 5_390_000.0, result[:taxable_estate], 0.01
    assert result[:estate_tax] > 0
    assert_equal 1_000_000.0, result[:deductions]
  end

  # --- Tax calculation accuracy ---

  test "tax on small taxable amount uses lower brackets" do
    # Estate just $50,000 over exemption
    calc = Finance::EstateTaxCalculator.new(estate_value: 13_660_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert_in_delta 50_000.0, result[:taxable_estate], 0.01
    # First $10,001 at 18%, next $10,000 at 20%, next $20,000 at 22%, last $10,000 at 24%
    expected_tax = (10_001 * 0.18) + (10_000 * 0.20) + (20_000 * 0.22) + (9_999 * 0.24)
    assert_in_delta expected_tax, result[:estate_tax], 1.0
  end

  # --- Zero / Negative values ---

  test "zero estate value returns error" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 0)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Estate value must be positive"
  end

  test "negative estate value returns error" do
    calc = Finance::EstateTaxCalculator.new(estate_value: -1_000_000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Estate value must be positive"
  end

  test "invalid filing status returns error" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 15_000_000, filing_status: "joint")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Invalid filing status"
  end

  test "negative deductions returns error" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 15_000_000, deductions: -500_000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Deductions cannot be negative"
  end

  test "deductions exceeding estate value returns error" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 1_000_000, deductions: 2_000_000)
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Deductions cannot exceed estate value"
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    calc = Finance::EstateTaxCalculator.new(estate_value: "15000000", deductions: "500000")
    result = calc.call

    assert result[:valid]
    assert result[:estate_tax] >= 0
  end

  # --- Large numbers ---

  test "very large estate still computes" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 1_000_000_000)
    result = calc.call

    assert result[:valid]
    assert result[:estate_tax] > 0
    # Effective rate should approach 40% for very large estates
    assert result[:effective_rate] > 30
  end

  # --- Effective rate ---

  test "effective rate is zero when no tax owed" do
    calc = Finance::EstateTaxCalculator.new(estate_value: 1_000_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert_in_delta 0.0, result[:effective_rate], 0.01
  end

  # --- Multiple errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::EstateTaxCalculator.new(
      estate_value: -1, filing_status: "bogus", deductions: -1
    )
    result = calc.call

    refute result[:valid]
    assert calc.errors.size >= 3
  end
end
