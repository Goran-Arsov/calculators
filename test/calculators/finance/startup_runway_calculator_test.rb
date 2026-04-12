require "test_helper"

class Finance::StartupRunwayCalculatorTest < ActiveSupport::TestCase
  test "happy path: simple runway calculation" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 500_000, monthly_burn: 50_000,
      monthly_revenue: 0, revenue_growth_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_equal 10, result[:gross_runway_months]
    assert_in_delta 50_000, result[:net_burn], 0.01
    assert_in_delta 50_000.0 / 30, result[:daily_burn], 0.01
    refute result[:is_profitable]
  end

  test "revenue reduces net burn" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 500_000, monthly_burn: 50_000,
      monthly_revenue: 20_000, revenue_growth_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 30_000, result[:net_burn], 0.01
    assert_equal 16, result[:gross_runway_months]
  end

  test "profitable startup has nil runway" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 100_000, monthly_burn: 30_000,
      monthly_revenue: 40_000, revenue_growth_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert_nil result[:gross_runway_months]
    assert result[:is_profitable]
  end

  test "revenue growth extends runway" do
    without_growth = Finance::StartupRunwayCalculator.new(
      cash_balance: 300_000, monthly_burn: 50_000,
      monthly_revenue: 10_000, revenue_growth_rate: 0
    ).call

    with_growth = Finance::StartupRunwayCalculator.new(
      cash_balance: 300_000, monthly_burn: 50_000,
      monthly_revenue: 10_000, revenue_growth_rate: 15
    ).call

    assert without_growth[:gross_runway_months].present?
    # With 15% monthly growth, revenue will exceed burn, giving infinite runway
    assert_nil(with_growth[:adjusted_runway_months]) || (with_growth[:adjusted_runway_months] > without_growth[:gross_runway_months])
  end

  test "zero cash balance returns error" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 0, monthly_burn: 50_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Cash balance must be positive"
  end

  test "zero burn rate returns error" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 500_000, monthly_burn: 0
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly burn rate must be positive"
  end

  test "negative revenue returns error" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 500_000, monthly_burn: 50_000,
      monthly_revenue: -10_000
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly revenue cannot be negative"
  end

  test "projection is included" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: 300_000, monthly_burn: 50_000,
      monthly_revenue: 10_000, revenue_growth_rate: 0
    )
    result = calc.call

    assert result[:valid]
    assert result[:projection].is_a?(Array)
    assert result[:projection].length > 0
    assert result[:projection].first.key?(:month)
    assert result[:projection].first.key?(:cash_remaining)
  end

  test "string inputs are coerced" do
    calc = Finance::StartupRunwayCalculator.new(
      cash_balance: "500000", monthly_burn: "50000",
      monthly_revenue: "10000", revenue_growth_rate: "5"
    )
    result = calc.call

    assert result[:valid]
  end
end
