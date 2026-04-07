require "test_helper"

class Everyday::PxToRemCalculatorTest < ActiveSupport::TestCase
  test "converts 16px to 1rem with default base" do
    result = Everyday::PxToRemCalculator.new(px_value: 16).call
    assert result[:valid]
    assert_equal 1.0, result[:rem_value]
    assert_equal 1.0, result[:em_value]
    assert_equal 12.0, result[:pt_value]
    assert_equal 100.0, result[:percentage]
  end

  test "converts 24px to 1.5rem with default base" do
    result = Everyday::PxToRemCalculator.new(px_value: 24).call
    assert result[:valid]
    assert_equal 1.5, result[:rem_value]
  end

  test "converts 8px to 0.5rem with default base" do
    result = Everyday::PxToRemCalculator.new(px_value: 8).call
    assert result[:valid]
    assert_equal 0.5, result[:rem_value]
    assert_equal 50.0, result[:percentage]
  end

  test "handles custom base font size" do
    result = Everyday::PxToRemCalculator.new(px_value: 20, base_font_size: 10).call
    assert result[:valid]
    assert_equal 2.0, result[:rem_value]
    assert_equal 200.0, result[:percentage]
  end

  test "handles zero px value" do
    result = Everyday::PxToRemCalculator.new(px_value: 0).call
    assert result[:valid]
    assert_equal 0.0, result[:rem_value]
    assert_equal 0.0, result[:pt_value]
    assert_equal 0.0, result[:percentage]
  end

  test "handles fractional px value" do
    result = Everyday::PxToRemCalculator.new(px_value: 14.5).call
    assert result[:valid]
    assert_in_delta 0.9063, result[:rem_value], 0.001
  end

  test "calculates pt correctly" do
    result = Everyday::PxToRemCalculator.new(px_value: 32).call
    assert result[:valid]
    assert_equal 24.0, result[:pt_value]
  end

  test "returns error for zero base font size" do
    result = Everyday::PxToRemCalculator.new(px_value: 16, base_font_size: 0).call
    assert_not result[:valid]
    assert_includes result[:errors], "Base font size must be greater than zero"
  end

  test "returns error for negative base font size" do
    result = Everyday::PxToRemCalculator.new(px_value: 16, base_font_size: -1).call
    assert_not result[:valid]
    assert_includes result[:errors], "Base font size must be greater than zero"
  end

  test "handles very large px value" do
    result = Everyday::PxToRemCalculator.new(px_value: 1000).call
    assert result[:valid]
    assert_equal 62.5, result[:rem_value]
  end

  test "returns all expected keys" do
    result = Everyday::PxToRemCalculator.new(px_value: 16).call
    assert result[:valid]
    assert_equal 16.0, result[:px_value]
    assert_equal 16.0, result[:base_font_size]
    assert result.key?(:rem_value)
    assert result.key?(:em_value)
    assert result.key?(:pt_value)
    assert result.key?(:percentage)
  end
end
