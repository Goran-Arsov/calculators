require "test_helper"

class Finance::TaxBracketCalculatorTest < ActiveSupport::TestCase
  # --- Single filer happy paths ---

  test "single filer: income within first bracket" do
    calc = Finance::TaxBracketCalculator.new(income: 10_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert_in_delta 1_000.00, result[:total_tax], 0.01       # 10% of 10,000
    assert_in_delta 10.00, result[:effective_rate], 0.01
    assert_equal 10, result[:marginal_rate]
    assert_in_delta 9_000.00, result[:after_tax_income], 0.01
  end

  test "single filer: income spanning two brackets" do
    calc = Finance::TaxBracketCalculator.new(income: 30_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    # 10% on first $11,601 (0..11600) = $1,160.10
    # 12% on $18,399 (11601..30000) = $2,207.88
    expected_tax = (11_601 * 0.10) + (18_399 * 0.12)
    assert_in_delta expected_tax, result[:total_tax], 0.01
    assert_equal 12, result[:marginal_rate]
    assert_equal 2, result[:breakdown].size
  end

  test "single filer: income of 85,000 spans three brackets" do
    calc = Finance::TaxBracketCalculator.new(income: 85_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    # 10% on $11,601 = $1,160.10
    # 12% on $35,550 (11601..47150) = $4,266.00
    # 22% on $37,849 (47151..85000) = $8,326.78
    expected_tax = (11_601 * 0.10) + (35_550 * 0.12) + (37_849 * 0.22)
    assert_in_delta expected_tax, result[:total_tax], 0.01
    assert_equal 22, result[:marginal_rate]
    assert_equal 3, result[:breakdown].size
  end

  test "single filer: high income hits all brackets" do
    calc = Finance::TaxBracketCalculator.new(income: 700_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert_equal 37, result[:marginal_rate]
    assert_equal 7, result[:breakdown].size
    assert result[:effective_rate] < 37.0
    assert result[:effective_rate] > 10.0
    assert_in_delta 700_000 - result[:total_tax], result[:after_tax_income], 0.01
  end

  # --- Married Filing Jointly ---

  test "married filing jointly: income within first bracket" do
    calc = Finance::TaxBracketCalculator.new(income: 20_000, filing_status: "married_filing_jointly")
    result = calc.call

    assert result[:valid]
    assert_in_delta 2_000.00, result[:total_tax], 0.01
    assert_equal 10, result[:marginal_rate]
  end

  test "married filing jointly: income of 150,000" do
    calc = Finance::TaxBracketCalculator.new(income: 150_000, filing_status: "married_filing_jointly")
    result = calc.call

    assert result[:valid]
    # 10% on $23,201 = $2,320.10
    # 12% on $71,100 (23201..94300) = $8,532.00
    # 22% on $55,699 (94301..150000) = $12,253.78
    expected_tax = (23_201 * 0.10) + (71_100 * 0.12) + (55_699 * 0.22)
    assert_in_delta expected_tax, result[:total_tax], 0.01
    assert_equal 22, result[:marginal_rate]
  end

  # --- Married Filing Separately ---

  test "married filing separately: same brackets as single" do
    single = Finance::TaxBracketCalculator.new(income: 85_000, filing_status: "single")
    mfs = Finance::TaxBracketCalculator.new(income: 85_000, filing_status: "married_filing_separately")

    assert_in_delta single.call[:total_tax], mfs.call[:total_tax], 0.01
  end

  # --- Head of Household ---

  test "head of household: income of 50,000" do
    calc = Finance::TaxBracketCalculator.new(income: 50_000, filing_status: "head_of_household")
    result = calc.call

    assert result[:valid]
    # 10% on $16,551 = $1,655.10
    # 12% on $33,449 (16551..50000) = $4,013.88
    expected_tax = (16_551 * 0.10) + (33_449 * 0.12)
    assert_in_delta expected_tax, result[:total_tax], 0.01
    assert_equal 12, result[:marginal_rate]
  end

  # --- Effective rate is always less than marginal ---

  test "effective rate is always less than or equal to marginal rate" do
    calc = Finance::TaxBracketCalculator.new(income: 200_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert result[:effective_rate] < result[:marginal_rate]
  end

  # --- Breakdown detail ---

  test "breakdown contains rate, taxable amount, and tax for each bracket" do
    calc = Finance::TaxBracketCalculator.new(income: 50_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    result[:breakdown].each do |bracket|
      assert bracket.key?(:rate)
      assert bracket.key?(:taxable_amount)
      assert bracket.key?(:tax)
      assert bracket[:taxable_amount] > 0
      assert bracket[:tax] > 0
    end
  end

  # --- Validation: negative income ---

  test "negative income returns error" do
    calc = Finance::TaxBracketCalculator.new(income: -50_000, filing_status: "single")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Taxable income must be positive"
  end

  # --- Validation: zero income ---

  test "zero income returns error" do
    calc = Finance::TaxBracketCalculator.new(income: 0, filing_status: "single")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Taxable income must be positive"
  end

  # --- Validation: invalid filing status ---

  test "invalid filing status returns error" do
    calc = Finance::TaxBracketCalculator.new(income: 50_000, filing_status: "invalid")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Filing status is not valid"
  end

  test "empty filing status returns error" do
    calc = Finance::TaxBracketCalculator.new(income: 50_000, filing_status: "")
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Filing status is not valid"
  end

  # --- Multiple validation errors ---

  test "multiple validation errors returned at once" do
    calc = Finance::TaxBracketCalculator.new(income: 0, filing_status: "bogus")
    result = calc.call

    refute result[:valid]
    assert_equal 2, calc.errors.size
    assert_includes calc.errors, "Taxable income must be positive"
    assert_includes calc.errors, "Filing status is not valid"
  end

  # --- String coercion ---

  test "string inputs are coerced" do
    calc = Finance::TaxBracketCalculator.new(income: "85000", filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert result[:total_tax] > 0
  end

  # --- Very large income ---

  test "very large income still computes" do
    calc = Finance::TaxBracketCalculator.new(income: 10_000_000, filing_status: "single")
    result = calc.call

    assert result[:valid]
    assert result[:total_tax] > 0
    assert_equal 37, result[:marginal_rate]
    assert_equal 7, result[:breakdown].size
  end

  # --- Income at exact bracket boundary ---

  test "income exactly at bracket boundary" do
    calc = Finance::TaxBracketCalculator.new(income: 11_600, filing_status: "single")
    result = calc.call

    assert result[:valid]
    # All income in the 10% bracket: first bracket is 0..11600 = 11601 wide
    # Income of 11600 is within first bracket
    assert_in_delta 1_160.00, result[:total_tax], 0.01
    assert_equal 10, result[:marginal_rate]
    assert_equal 1, result[:breakdown].size
  end
end
