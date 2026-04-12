require "test_helper"

class Relationships::MilestonesCalculatorTest < ActiveSupport::TestCase
  test "older relationship has more milestones passed" do
    new_rel = Relationships::MilestonesCalculator.new(start_date: "2023-01-01", reference_date: "2024-01-01").call
    old_rel = Relationships::MilestonesCalculator.new(start_date: "2018-01-01", reference_date: "2024-01-01").call
    new_passed = new_rel[:milestones].count { |m| m[:passed] }
    old_passed = old_rel[:milestones].count { |m| m[:passed] }
    assert old_passed > new_passed
  end

  test "next milestone returned" do
    result = Relationships::MilestonesCalculator.new(start_date: "2024-01-01", reference_date: "2024-06-01").call
    assert result[:next_milestone].present?
  end

  test "future start errors" do
    result = Relationships::MilestonesCalculator.new(start_date: "2999-01-01").call
    assert_equal false, result[:valid]
  end
end
