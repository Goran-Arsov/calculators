require "test_helper"

class Relationships::AgeGapCalculatorTest < ActiveSupport::TestCase
  test "exact 3 year gap" do
    result = Relationships::AgeGapCalculator.new(birth1: "1990-01-01", birth2: "1993-01-01").call
    assert result[:valid]
    assert_equal 3, result[:years]
    assert_equal 0, result[:months]
    assert_equal 0, result[:days]
  end

  test "younger first works the same" do
    result = Relationships::AgeGapCalculator.new(birth1: "1993-01-01", birth2: "1990-01-01").call
    assert_equal 3, result[:years]
  end

  test "half plus seven check passes for 30 and 27" do
    today = Date.today
    result = Relationships::AgeGapCalculator.new(
      birth1: (today - 30 * 365).to_s,
      birth2: (today - 27 * 365).to_s
    ).call
    assert result[:rule_passes]
  end

  test "future birth dates error" do
    result = Relationships::AgeGapCalculator.new(birth1: "2999-01-01", birth2: "2000-01-01").call
    assert_equal false, result[:valid]
  end
end
