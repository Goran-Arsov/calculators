require "test_helper"

class Finance::CostPerAcquisitionCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic CPA: total_cost=10000, customers=50 -> CPA=$200" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50).call
    assert result[:valid]
    assert_equal 200.0, result[:cost_per_acquisition]
    assert_equal 10_000.0, result[:total_cost]
    assert_equal 50, result[:customers]
  end

  test "CPA with customer LTV calculates ratio and ROI" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50, customer_ltv: 1000).call
    assert result[:valid]
    assert_equal 200.0, result[:cost_per_acquisition]
    assert_equal 5.0, result[:ltv_cpa_ratio]
    assert_equal 400.0, result[:roi]
  end

  test "CPA with low LTV yields negative ROI" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50, customer_ltv: 100).call
    assert result[:valid]
    assert_equal 200.0, result[:cost_per_acquisition]
    assert_equal 0.5, result[:ltv_cpa_ratio]
    assert_equal(-50.0, result[:roi])
  end

  test "string coercion works for numeric inputs" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: "10000", customers: "50").call
    assert result[:valid]
    assert_equal 200.0, result[:cost_per_acquisition]
  end

  test "large numbers: total_cost=1000000, customers=5000" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 1_000_000, customers: 5000).call
    assert result[:valid]
    assert_equal 200.0, result[:cost_per_acquisition]
  end

  # --- Without optional LTV ---

  test "result does not include LTV fields without customer_ltv" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50).call
    assert result[:valid]
    refute result.key?(:ltv_cpa_ratio)
    refute result.key?(:roi)
  end

  # --- Validation errors ---

  test "error when total cost is zero" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 0, customers: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Total cost must be positive"
  end

  test "error when customers is zero" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Customers must be positive"
  end

  test "error when total cost is negative" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: -500, customers: 10).call
    refute result[:valid]
    assert_includes result[:errors], "Total cost must be positive"
  end

  test "error when customer LTV is negative" do
    result = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50, customer_ltv: -100).call
    refute result[:valid]
    assert_includes result[:errors], "Customer LTV must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::CostPerAcquisitionCalculator.new(total_cost: 10_000, customers: 50)
    assert_equal [], calc.errors
  end
end
