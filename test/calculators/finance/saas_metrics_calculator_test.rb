require "test_helper"

class Finance::SaasMetricsCalculatorTest < ActiveSupport::TestCase
  test "happy path: standard SaaS metrics" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 50_000, churned_subscriptions: 15,
      total_customers: 500, new_customers: 30, cac: 500
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 50_000, result[:mrr], 0.01
    assert_in_delta 600_000, result[:arr], 0.01
    assert_in_delta 3.0, result[:churn_rate], 0.01 # 15/500 * 100
    assert_in_delta 100, result[:arpu], 0.01 # 50000 / 500
    assert result[:ltv] > 0
    assert result[:ltv_cac_ratio] > 0
    assert result[:cac_payback_months] > 0
    assert result[:quick_ratio] > 0
  end

  test "ARR is MRR times 12" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 5,
      total_customers: 100, new_customers: 10, cac: 200
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 120_000, result[:arr], 0.01
  end

  test "LTV calculation: ARPU divided by churn rate" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 5,
      total_customers: 100, new_customers: 10, cac: 200
    )
    result = calc.call

    # ARPU = 10000/100 = 100, churn = 5/100 = 5%, LTV = 100/0.05 = 2000
    assert_in_delta 2_000, result[:ltv], 0.01
  end

  test "LTV:CAC ratio" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 5,
      total_customers: 100, new_customers: 10, cac: 500
    )
    result = calc.call

    # LTV = 2000, CAC = 500, ratio = 4.0
    assert_in_delta 4.0, result[:ltv_cac_ratio], 0.01
  end

  test "zero churn gives zero LTV" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 0,
      total_customers: 100, new_customers: 10, cac: 200
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 0, result[:churn_rate], 0.01
    assert_in_delta 0, result[:ltv], 0.01
  end

  test "ARPU override" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 5,
      total_customers: 100, new_customers: 10, cac: 200,
      avg_revenue_per_user: 150
    )
    result = calc.call

    assert result[:valid]
    assert_in_delta 150, result[:arpu], 0.01
  end

  test "zero MRR returns error" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 0, churned_subscriptions: 0,
      total_customers: 100, new_customers: 10, cac: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Monthly subscriptions (MRR) must be positive"
  end

  test "zero customers returns error" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 0,
      total_customers: 0, new_customers: 0, cac: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Total customers must be positive"
  end

  test "churned exceeds total returns error" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 200,
      total_customers: 100, new_customers: 10, cac: 200
    )
    result = calc.call

    refute result[:valid]
    assert_includes calc.errors, "Churned subscriptions cannot exceed total customers"
  end

  test "CAC payback months" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: 10_000, churned_subscriptions: 5,
      total_customers: 100, new_customers: 10, cac: 350
    )
    result = calc.call

    # ARPU = 100, CAC = 350, payback = ceil(350/100) = 4
    assert_equal 4, result[:cac_payback_months]
  end

  test "string inputs are coerced" do
    calc = Finance::SaasMetricsCalculator.new(
      monthly_subscriptions: "50000", churned_subscriptions: "15",
      total_customers: "500", new_customers: "30", cac: "500"
    )
    result = calc.call

    assert result[:valid]
    assert result[:mrr] > 0
  end
end
