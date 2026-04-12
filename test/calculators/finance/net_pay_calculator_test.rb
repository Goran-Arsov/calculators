require "test_helper"

class Finance::NetPayCalculatorTest < ActiveSupport::TestCase
  test "US: single filer at $75,000" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 75_000, country: "us",
      filing_status: "single", pay_frequency: "monthly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:net_annual] > 0
    assert result[:net_annual] < 75_000
    assert result[:total_deductions] > 0
    assert result[:effective_tax_rate] > 0
    assert_equal 12, result[:pay_periods]
    assert result[:deductions].key?(:federal_tax)
    assert result[:deductions].key?(:social_security)
    assert result[:deductions].key?(:medicare)
  end

  test "US: married filer pays less tax than single" do
    single = Finance::NetPayCalculator.new(
      gross_salary: 100_000, country: "us",
      filing_status: "single", pay_frequency: "annual"
    ).call

    married = Finance::NetPayCalculator.new(
      gross_salary: 100_000, country: "us",
      filing_status: "married", pay_frequency: "annual"
    ).call

    assert married[:net_annual] > single[:net_annual]
  end

  test "UK: standard salary" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 50_000, country: "uk",
      filing_status: "single", pay_frequency: "monthly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:deductions].key?(:income_tax)
    assert result[:deductions].key?(:national_insurance)
    assert result[:net_annual] > 0
  end

  test "Canada: standard salary" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 60_000, country: "ca",
      filing_status: "single", pay_frequency: "biweekly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:deductions].key?(:federal_tax)
    assert result[:deductions].key?(:cpp)
    assert result[:deductions].key?(:ei)
    assert_equal 26, result[:pay_periods]
  end

  test "Australia: standard salary" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 80_000, country: "au",
      filing_status: "single", pay_frequency: "weekly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:deductions].key?(:income_tax)
    assert result[:deductions].key?(:medicare_levy)
    assert_equal 52, result[:pay_periods]
  end

  test "zero salary returns error" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 0, country: "us",
      filing_status: "single", pay_frequency: "annual"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Gross salary must be positive"
  end

  test "invalid country returns error" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 75_000, country: "jp",
      filing_status: "single", pay_frequency: "annual"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Country must be us, uk, ca, or au"
  end

  test "invalid pay frequency returns error" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 75_000, country: "us",
      filing_status: "single", pay_frequency: "daily"
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Pay frequency must be annual, monthly, biweekly, or weekly"
  end

  test "US: high earner Medicare surcharge" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: 250_000, country: "us",
      filing_status: "single", pay_frequency: "annual"
    )
    result = calc.call

    assert result[:valid]
    # Medicare should include additional 0.9% on income above $200k
    expected_medicare = 250_000 * 0.0145 + 50_000 * 0.009
    assert_in_delta expected_medicare, result[:deductions][:medicare], 1.0
  end

  test "string inputs are coerced" do
    calc = Finance::NetPayCalculator.new(
      gross_salary: "75000", country: "us",
      filing_status: "single", pay_frequency: "monthly"
    )
    result = calc.call

    assert result[:valid]
    assert result[:net_annual] > 0
  end
end
