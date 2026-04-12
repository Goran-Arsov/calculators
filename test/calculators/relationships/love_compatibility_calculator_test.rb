require "test_helper"

class Relationships::LoveCompatibilityCalculatorTest < ActiveSupport::TestCase
  test "valid two names produce a percentage 40-99" do
    result = Relationships::LoveCompatibilityCalculator.new(name1: "Alex", name2: "Sam").call
    assert result[:valid]
    assert (40..99).cover?(result[:percentage])
    assert result[:label].present?
  end

  test "same names give the same result" do
    a = Relationships::LoveCompatibilityCalculator.new(name1: "Robin", name2: "Casey").call
    b = Relationships::LoveCompatibilityCalculator.new(name1: "Robin", name2: "Casey").call
    assert_equal a[:percentage], b[:percentage]
  end

  test "blank names error" do
    result = Relationships::LoveCompatibilityCalculator.new(name1: "", name2: "Sam").call
    assert_equal false, result[:valid]
  end
end
