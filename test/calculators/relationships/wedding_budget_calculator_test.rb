require "test_helper"

class Relationships::WeddingBudgetCalculatorTest < ActiveSupport::TestCase
  test "33000 budget at 117 guests" do
    result = Relationships::WeddingBudgetCalculator.new(total_budget: 33000, guest_count: 117).call
    assert result[:valid]
    assert_in_delta 282.05, result[:cost_per_guest], 0.5
    assert_in_delta 12210, result[:breakdown][:venue], 0.1 # 33000 * 0.37
  end

  test "negative budget errors" do
    result = Relationships::WeddingBudgetCalculator.new(total_budget: -1000, guest_count: 50).call
    assert_equal false, result[:valid]
  end

  test "breakdown sums to 100 percent of total" do
    result = Relationships::WeddingBudgetCalculator.new(total_budget: 50000, guest_count: 100).call
    assert_in_delta 50000, result[:breakdown].values.sum, 1.0
  end
end
