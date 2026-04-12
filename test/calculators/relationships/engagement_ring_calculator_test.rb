require "test_helper"

class Relationships::EngagementRingCalculatorTest < ActiveSupport::TestCase
  test "two month rule on 60000 salary" do
    result = Relationships::EngagementRingCalculator.new(annual_salary: 60000, rule: "two").call
    assert result[:valid]
    assert_in_delta 10000, result[:target], 0.01
  end

  test "low and high are 70 and 130 percent of target" do
    result = Relationships::EngagementRingCalculator.new(annual_salary: 60000, rule: "two").call
    assert_in_delta 7000, result[:low], 0.01
    assert_in_delta 13000, result[:high], 0.01
  end

  test "invalid rule errors" do
    result = Relationships::EngagementRingCalculator.new(annual_salary: 60000, rule: "five").call
    assert_equal false, result[:valid]
  end
end
