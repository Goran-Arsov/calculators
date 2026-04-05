require "test_helper"

class Finance::HourlyToProjectCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: basic project ---

  test "$75/hour x 40 hours + $200 expenses + 20% tax" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 40, expenses: 200, tax_rate: 20
    ).call

    assert result[:valid]
    assert_equal 3_000.0, result[:labor_cost]
    assert_equal 3_200.0, result[:subtotal]
    assert_equal 640.0, result[:tax_amount]
    assert_equal 3_840.0, result[:project_total]
    assert_equal 96.0, result[:effective_hourly_rate]
    assert_equal 2_400.0, result[:after_tax_income]
  end

  # --- Happy path: no tax, no expenses ---

  test "basic project with zero tax and zero expenses" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 50, estimated_hours: 20
    ).call

    assert result[:valid]
    assert_equal 1_000.0, result[:labor_cost]
    assert_equal 1_000.0, result[:subtotal]
    assert_equal 0.0, result[:tax_amount]
    assert_equal 1_000.0, result[:project_total]
    assert_equal 50.0, result[:effective_hourly_rate]
    assert_equal 1_000.0, result[:after_tax_income]
  end

  # --- Effective rate includes expenses ---

  test "effective rate increases with expenses" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 100, estimated_hours: 10, expenses: 500
    ).call

    assert result[:valid]
    # total = 1000 + 500 = 1500, effective = 1500/10 = 150
    assert_equal 150.0, result[:effective_hourly_rate]
  end

  # --- After-tax income ---

  test "after-tax income is reduced by tax rate" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 100, estimated_hours: 10, tax_rate: 30
    ).call

    assert result[:valid]
    assert_equal 700.0, result[:after_tax_income]
  end

  # --- Validation errors ---

  test "error when hourly rate is zero" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 0, estimated_hours: 40
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Hourly rate must be greater than zero"
  end

  test "error when estimated hours is zero" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Estimated hours must be greater than zero"
  end

  test "error when expenses is negative" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 40, expenses: -100
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Expenses cannot be negative"
  end

  test "error when tax rate is negative" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 40, tax_rate: -10
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Tax rate cannot be negative"
  end

  test "error when tax rate exceeds 100" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 40, tax_rate: 101
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Tax rate cannot exceed 100%"
  end

  test "multiple errors at once" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 0, estimated_hours: 0, expenses: -10, tax_rate: -5
    ).call

    refute result[:valid]
    assert result[:errors].size >= 4
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: "75", estimated_hours: "40", expenses: "200", tax_rate: "20"
    ).call

    assert result[:valid]
    assert_equal 3_000.0, result[:labor_cost]
  end

  # --- Edge cases ---

  test "very high hourly rate still computes" do
    result = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 1000, estimated_hours: 100, expenses: 5000, tax_rate: 10
    ).call

    assert result[:valid]
    assert_equal 100_000.0, result[:labor_cost]
    assert_equal 115_500.0, result[:project_total]
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::HourlyToProjectCalculator.new(
      hourly_rate: 75, estimated_hours: 40
    )
    assert_equal [], calc.errors
  end
end
