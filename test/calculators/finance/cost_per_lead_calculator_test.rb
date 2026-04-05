require "test_helper"

class Finance::CostPerLeadCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "basic CPL: total_spend=5000, leads=100 -> CPL=$50" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100).call
    assert result[:valid]
    assert_equal 50.0, result[:cost_per_lead]
    assert_equal 5000.0, result[:total_spend]
    assert_equal 100, result[:leads]
  end

  test "CPL with qualified leads" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100, qualified_leads: 25).call
    assert result[:valid]
    assert_equal 50.0, result[:cost_per_lead]
    assert_equal 200.0, result[:cost_per_qualified_lead]
    assert_equal 25.0, result[:qualification_rate]
  end

  test "CPL with total visitors for conversion rate" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100, total_visitors: 10_000).call
    assert result[:valid]
    assert_equal 50.0, result[:cost_per_lead]
    assert_equal 1.0, result[:conversion_rate]
  end

  test "all optional fields provided" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 10_000, leads: 200, qualified_leads: 50, total_visitors: 20_000).call
    assert result[:valid]
    assert_equal 50.0, result[:cost_per_lead]
    assert_equal 200.0, result[:cost_per_qualified_lead]
    assert_equal 25.0, result[:qualification_rate]
    assert_equal 1.0, result[:conversion_rate]
  end

  test "string coercion works for numeric inputs" do
    result = Finance::CostPerLeadCalculator.new(total_spend: "5000", leads: "100").call
    assert result[:valid]
    assert_equal 50.0, result[:cost_per_lead]
  end

  # --- Validation errors ---

  test "error when total spend is zero" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 0, leads: 100).call
    refute result[:valid]
    assert_includes result[:errors], "Total spend must be positive"
  end

  test "error when leads is zero" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 0).call
    refute result[:valid]
    assert_includes result[:errors], "Leads must be positive"
  end

  test "error when total spend is negative" do
    result = Finance::CostPerLeadCalculator.new(total_spend: -100, leads: 50).call
    refute result[:valid]
    assert_includes result[:errors], "Total spend must be positive"
  end

  test "error when qualified leads exceed total leads" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100, qualified_leads: 150).call
    refute result[:valid]
    assert_includes result[:errors], "Qualified leads cannot exceed total leads"
  end

  test "error when total visitors is negative" do
    result = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100, total_visitors: -1).call
    refute result[:valid]
    assert_includes result[:errors], "Total visitors must be positive"
  end

  test "errors accessor returns empty array before call" do
    calc = Finance::CostPerLeadCalculator.new(total_spend: 5000, leads: 100)
    assert_equal [], calc.errors
  end
end
