require "test_helper"

class Relationships::WeddingSplitterCalculatorTest < ActiveSupport::TestCase
  test "modern split puts couple at half" do
    result = Relationships::WeddingSplitterCalculator.new(total_cost: 30000, mode: "modern").call
    assert result[:valid]
    assert_in_delta 15000, result[:couple], 0.01
  end

  test "traditional split puts most on bride's family" do
    result = Relationships::WeddingSplitterCalculator.new(total_cost: 30000, mode: "traditional").call
    assert_in_delta 16500, result[:brides_family], 0.01
  end

  test "even split is one third each" do
    result = Relationships::WeddingSplitterCalculator.new(total_cost: 30000, mode: "even").call
    assert_in_delta 10000, result[:couple], 0.01
  end

  test "invalid mode errors" do
    result = Relationships::WeddingSplitterCalculator.new(total_cost: 30000, mode: "futuristic").call
    assert_equal false, result[:valid]
  end
end
