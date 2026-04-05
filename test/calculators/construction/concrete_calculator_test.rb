require "test_helper"

class Construction::ConcreteCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "10x10x4 inches → cubic yards > 0" do
    result = Construction::ConcreteCalculator.new(length_ft: 10, width_ft: 10, depth_in: 4).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:cubic_yards] > 0
    assert result[:cubic_feet] > 0
  end

  test "cubic feet calculated correctly" do
    result = Construction::ConcreteCalculator.new(length_ft: 10, width_ft: 10, depth_in: 12).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 10 * 10 * 1 = 100 cubic feet
    assert_equal 100.0, result[:cubic_feet]
    # 100 / 27 ≈ 3.70
    assert_in_delta 3.70, result[:cubic_yards], 0.01
  end

  test "bag counts are positive integers" do
    result = Construction::ConcreteCalculator.new(length_ft: 10, width_ft: 10, depth_in: 4).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:bags_60lb] > 0
    assert result[:bags_80lb] > 0
    assert result[:bags_60lb] > result[:bags_80lb]
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::ConcreteCalculator.new(length_ft: 0, width_ft: 10, depth_in: 4).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when depth is zero" do
    result = Construction::ConcreteCalculator.new(length_ft: 10, width_ft: 10, depth_in: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Depth must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ConcreteCalculator.new(length_ft: 10, width_ft: 10, depth_in: 4)
    assert_equal [], calc.errors
  end
end
