require "test_helper"

class Relationships::DivorceCostCalculatorTest < ActiveSupport::TestCase
  test "uncontested base cost" do
    result = Relationships::DivorceCostCalculator.new(path: "uncontested").call
    assert result[:valid]
    assert_equal 1000, result[:low_estimate]
    assert_equal 2500, result[:mid_estimate]
  end

  test "contested costs more than uncontested" do
    uncontested = Relationships::DivorceCostCalculator.new(path: "uncontested").call
    contested = Relationships::DivorceCostCalculator.new(path: "contested").call
    assert contested[:mid_estimate] > uncontested[:mid_estimate]
  end

  test "extras add to estimate" do
    base = Relationships::DivorceCostCalculator.new(path: "mediated").call
    with_kids = Relationships::DivorceCostCalculator.new(path: "mediated", has_children: true).call
    assert with_kids[:mid_estimate] > base[:mid_estimate]
  end

  test "all three extras add together" do
    result = Relationships::DivorceCostCalculator.new(
      path: "mediated", has_children: true, has_property: true, has_business: true
    ).call
    assert_equal 3500 + 4500 + 8000, result[:extras]
  end

  test "invalid path errors" do
    result = Relationships::DivorceCostCalculator.new(path: "instant").call
    assert_equal false, result[:valid]
  end
end
