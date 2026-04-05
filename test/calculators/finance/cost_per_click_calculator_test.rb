require "test_helper"

class Finance::CostPerClickCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic CPC: total_spend=500, clicks=250 -> CPC=$2.00" do
    result = Finance::CostPerClickCalculator.new(total_spend: 500, clicks: 250).call
    assert result[:valid]
    assert_equal 2.0, result[:cost_per_click]
    assert_equal 500.0, result[:total_spend]
    assert_equal 250, result[:clicks]
  end

  test "CPC with impressions: calculates CPM and CTR" do
    result = Finance::CostPerClickCalculator.new(total_spend: 1000, clicks: 500, impressions: 100_000).call
    assert result[:valid]
    assert_equal 2.0, result[:cost_per_click]
    assert_equal 10.0, result[:cpm]
    assert_equal 0.5, result[:click_through_rate]
  end

  test "fractional CPC: total_spend=100, clicks=300" do
    result = Finance::CostPerClickCalculator.new(total_spend: 100, clicks: 300).call
    assert result[:valid]
    assert_in_delta 0.3333, result[:cost_per_click], 0.0001
  end

  test "large spend with many clicks" do
    result = Finance::CostPerClickCalculator.new(total_spend: 50_000, clicks: 12_500).call
    assert result[:valid]
    assert_equal 4.0, result[:cost_per_click]
  end

  test "string coercion works for numeric inputs" do
    result = Finance::CostPerClickCalculator.new(total_spend: "500", clicks: "250").call
    assert result[:valid]
    assert_equal 2.0, result[:cost_per_click]
  end

  # --- Without optional impressions ---

  test "result does not include CPM or CTR without impressions" do
    result = Finance::CostPerClickCalculator.new(total_spend: 500, clicks: 250).call
    assert result[:valid]
    refute result.key?(:cpm)
    refute result.key?(:click_through_rate)
  end

  # --- Validation errors ---

  test "error when total spend is zero" do
    result = Finance::CostPerClickCalculator.new(total_spend: 0, clicks: 100).call
    refute result[:valid]
    assert_includes result[:errors], "Total spend must be positive"
  end

  test "error when clicks is zero" do
    result = Finance::CostPerClickCalculator.new(total_spend: 500, clicks: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Clicks must be positive"
  end

  test "error when total spend is negative" do
    result = Finance::CostPerClickCalculator.new(total_spend: -100, clicks: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Total spend must be positive"
  end

  test "error when impressions is negative" do
    result = Finance::CostPerClickCalculator.new(total_spend: 500, clicks: 100, impressions: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Impressions must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::CostPerClickCalculator.new(total_spend: 500, clicks: 250)
    assert_equal [], calc.errors
  end
end
