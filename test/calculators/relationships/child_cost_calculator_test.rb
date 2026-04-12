require "test_helper"

class Relationships::ChildCostCalculatorTest < ActiveSupport::TestCase
  test "middle income mcol single child" do
    result = Relationships::ChildCostCalculator.new(income_tier: "middle", col: "mcol", num_children: 1).call
    assert result[:valid]
    assert_in_delta 310000, result[:total_cost], 1.0
  end

  test "two children get multi-child discount" do
    one = Relationships::ChildCostCalculator.new(income_tier: "middle", col: "mcol", num_children: 1).call
    two = Relationships::ChildCostCalculator.new(income_tier: "middle", col: "mcol", num_children: 2).call
    assert two[:total_cost] < (one[:total_cost] * 2)
  end

  test "hcol increases cost" do
    mcol = Relationships::ChildCostCalculator.new(income_tier: "middle", col: "mcol", num_children: 1).call
    hcol = Relationships::ChildCostCalculator.new(income_tier: "middle", col: "hcol", num_children: 1).call
    assert hcol[:total_cost] > mcol[:total_cost]
  end

  test "invalid tier errors" do
    result = Relationships::ChildCostCalculator.new(income_tier: "ultra", col: "mcol", num_children: 1).call
    assert_equal false, result[:valid]
  end
end
