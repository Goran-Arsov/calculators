require "test_helper"

class Relationships::FlamesCalculatorTest < ActiveSupport::TestCase
  test "valid pair returns one of six outcomes" do
    result = Relationships::FlamesCalculator.new(name1: "Alex", name2: "Jordan").call
    assert result[:valid]
    assert_includes %w[Friends Love Affection Marriage Enemies Siblings], result[:outcome]
  end

  test "same names always give same result" do
    a = Relationships::FlamesCalculator.new(name1: "Mike", name2: "Sara").call
    b = Relationships::FlamesCalculator.new(name1: "Mike", name2: "Sara").call
    assert_equal a[:outcome], b[:outcome]
  end

  test "blank name errors" do
    result = Relationships::FlamesCalculator.new(name1: "", name2: "Jordan").call
    assert_equal false, result[:valid]
  end
end
