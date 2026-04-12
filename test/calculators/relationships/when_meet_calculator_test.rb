require "test_helper"

class Relationships::WhenMeetCalculatorTest < ActiveSupport::TestCase
  test "medium effort medium city average" do
    result = Relationships::WhenMeetCalculator.new(
      city_size: "medium", effort: "medium", selectivity: "average"
    ).call
    assert result[:valid]
    assert result[:months_until_meet] > 0
    assert result[:months_until_meet] <= 60
  end

  test "high effort reduces time vs low" do
    high = Relationships::WhenMeetCalculator.new(
      city_size: "large", effort: "high", selectivity: "average"
    ).call
    low = Relationships::WhenMeetCalculator.new(
      city_size: "large", effort: "low", selectivity: "average"
    ).call
    assert high[:months_until_meet] < low[:months_until_meet]
  end

  test "invalid input errors" do
    result = Relationships::WhenMeetCalculator.new(
      city_size: "huge", effort: "high", selectivity: "average"
    ).call
    assert_equal false, result[:valid]
  end
end
