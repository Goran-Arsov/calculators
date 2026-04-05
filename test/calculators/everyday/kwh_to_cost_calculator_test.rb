require "test_helper"

class Everyday::KwhToCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: daily usage ---

  test "30 kWh/day at $0.12/kWh → daily cost $3.60" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 30, rate_per_kwh: 0.12, period: "daily"
    ).call

    assert result[:valid]
    assert_equal 3.60, result[:daily_cost]
    assert_equal 108.0, result[:monthly_cost]
    assert_equal 1314.0, result[:yearly_cost]
  end

  # --- Happy path: monthly usage ---

  test "900 kWh/month at $0.12/kWh → monthly cost $108" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 900, rate_per_kwh: 0.12, period: "monthly"
    ).call

    assert result[:valid]
    assert_in_delta 108.0, result[:monthly_cost], 0.01
    assert_in_delta 30.0, result[:daily_kwh], 0.01
  end

  # --- Happy path: yearly usage ---

  test "yearly usage converts correctly" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 10950, rate_per_kwh: 0.10, period: "yearly"
    ).call

    assert result[:valid]
    assert_in_delta 30.0, result[:daily_kwh], 0.01
    assert_in_delta 3.0, result[:daily_cost], 0.01
    assert_in_delta 1095.0, result[:yearly_cost], 0.01
  end

  # --- Validation errors ---

  test "error when kWh usage is zero" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 0, rate_per_kwh: 0.12, period: "daily"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "kWh usage must be greater than zero"
  end

  test "error when rate is negative" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 30, rate_per_kwh: -0.10, period: "daily"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Rate per kWh must be greater than zero"
  end

  test "error when period is invalid" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 30, rate_per_kwh: 0.12, period: "weekly"
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Invalid period"
  end

  test "multiple errors returned at once" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 0, rate_per_kwh: 0, period: "invalid"
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: "30", rate_per_kwh: "0.12", period: "daily"
    ).call

    assert result[:valid]
    assert_equal 3.60, result[:daily_cost]
  end

  # --- Edge cases ---

  test "very high rate produces large costs" do
    result = Everyday::KwhToCostCalculator.new(
      kwh_usage: 50, rate_per_kwh: 0.50, period: "daily"
    ).call

    assert result[:valid]
    assert_equal 25.0, result[:daily_cost]
    assert_equal 9125.0, result[:yearly_cost]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::KwhToCostCalculator.new(
      kwh_usage: 30, rate_per_kwh: 0.12, period: "daily"
    )
    assert_equal [], calc.errors
  end
end
