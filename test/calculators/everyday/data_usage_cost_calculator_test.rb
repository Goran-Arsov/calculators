require "test_helper"

class Everyday::DataUsageCostCalculatorTest < ActiveSupport::TestCase
  # --- Happy path: under plan limit ---

  test "20 GB plan, $50 cost, 15 GB used, no overage" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 15
    ).call

    assert result[:valid]
    assert_equal 2.5, result[:cost_per_gb]
    assert_equal 0.0, result[:overage_gb]
    assert_equal 0.0, result[:overage_cost]
    assert_equal 5.0, result[:unused_gb]
    assert_equal 12.5, result[:unused_data_value]
    assert_equal 50.0, result[:total_cost]
  end

  # --- Happy path: over plan limit ---

  test "20 GB plan, $50 cost, 25 GB used, $10/GB overage" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 25, overage_rate_per_gb: 10
    ).call

    assert result[:valid]
    assert_equal 5.0, result[:overage_gb]
    assert_equal 50.0, result[:overage_cost]
    assert_equal 0.0, result[:unused_gb]
    assert_equal 100.0, result[:total_cost]
  end

  # --- Happy path: exact usage ---

  test "exact plan usage has zero overage and zero unused" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 10, plan_cost: 30, actual_usage_gb: 10
    ).call

    assert result[:valid]
    assert_equal 0.0, result[:overage_gb]
    assert_equal 0.0, result[:unused_gb]
    assert_equal 30.0, result[:total_cost]
  end

  # --- Effective cost per GB ---

  test "effective cost per GB increases with unused data" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 5
    ).call

    assert result[:valid]
    # effective = 50 / 5 = 10.0, much higher than base 2.5
    assert_equal 10.0, result[:effective_cost_per_gb]
  end

  # --- Usage percentage ---

  test "usage percentage calculated correctly" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 15
    ).call

    assert result[:valid]
    assert_equal 75.0, result[:usage_percentage]
  end

  test "usage percentage can exceed 100" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 10, plan_cost: 30, actual_usage_gb: 15, overage_rate_per_gb: 5
    ).call

    assert result[:valid]
    assert_equal 150.0, result[:usage_percentage]
  end

  # --- Validation errors ---

  test "error when plan size is zero" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 0, plan_cost: 50, actual_usage_gb: 15
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Plan size must be greater than zero"
  end

  test "error when actual usage is zero" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 0
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Actual usage must be greater than zero"
  end

  test "error when overage rate is negative" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 25, overage_rate_per_gb: -5
    ).call

    refute result[:valid]
    assert_includes result[:errors], "Overage rate cannot be negative"
  end

  test "multiple errors at once" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 0, plan_cost: 0, actual_usage_gb: 0
    ).call

    refute result[:valid]
    assert_equal 3, result[:errors].size
  end

  # --- String coercion ---

  test "string inputs are coerced to numeric" do
    result = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: "20", plan_cost: "50", actual_usage_gb: "15"
    ).call

    assert result[:valid]
    assert_equal 2.5, result[:cost_per_gb]
  end

  # --- Edge cases ---

  test "errors accessor returns empty array before call" do
    calc = Everyday::DataUsageCostCalculator.new(
      plan_size_gb: 20, plan_cost: 50, actual_usage_gb: 15
    )
    assert_equal [], calc.errors
  end
end
