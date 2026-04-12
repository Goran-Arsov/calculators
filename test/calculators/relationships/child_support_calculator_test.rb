require "test_helper"

class Relationships::ChildSupportCalculatorTest < ActiveSupport::TestCase
  test "calculates positive monthly support" do
    result = Relationships::ChildSupportCalculator.new(
      payor_income: 80000, other_parent_income: 40000, num_children: 2
    ).call
    assert result[:valid]
    assert result[:monthly_amount].positive?
    assert_in_delta 66.7, result[:payor_share_percent], 0.5
  end

  test "more children means higher obligation" do
    one = Relationships::ChildSupportCalculator.new(
      payor_income: 80000, other_parent_income: 40000, num_children: 1
    ).call
    three = Relationships::ChildSupportCalculator.new(
      payor_income: 80000, other_parent_income: 40000, num_children: 3
    ).call
    assert three[:monthly_amount] > one[:monthly_amount]
  end

  test "zero income errors" do
    result = Relationships::ChildSupportCalculator.new(
      payor_income: 0, other_parent_income: 40000, num_children: 1
    ).call
    assert_equal false, result[:valid]
  end
end
