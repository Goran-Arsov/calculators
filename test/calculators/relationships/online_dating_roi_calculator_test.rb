require "test_helper"

class Relationships::OnlineDatingRoiCalculatorTest < ActiveSupport::TestCase
  test "default funnel produces a timeline" do
    result = Relationships::OnlineDatingRoiCalculator.new(
      messages_per_week: 20, response_rate_pct: 20, date_conversion_pct: 25, relationship_rate_pct: 10
    ).call
    assert result[:valid]
    assert result[:weeks_to_relationship].positive?
    assert result[:messages_needed].positive?
    assert result[:time_invested_hours].positive?
  end

  test "higher response rate gives faster timeline" do
    low = Relationships::OnlineDatingRoiCalculator.new(
      messages_per_week: 20, response_rate_pct: 5, date_conversion_pct: 25, relationship_rate_pct: 10
    ).call
    high = Relationships::OnlineDatingRoiCalculator.new(
      messages_per_week: 20, response_rate_pct: 30, date_conversion_pct: 25, relationship_rate_pct: 10
    ).call
    assert high[:weeks_to_relationship] < low[:weeks_to_relationship]
  end

  test "zero response rate errors" do
    result = Relationships::OnlineDatingRoiCalculator.new(
      messages_per_week: 20, response_rate_pct: 0, date_conversion_pct: 25, relationship_rate_pct: 10
    ).call
    assert_equal false, result[:valid]
  end
end
