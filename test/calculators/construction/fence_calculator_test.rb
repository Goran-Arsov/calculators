require "test_helper"

class Construction::FenceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "100ft fence → posts > 0" do
    result = Construction::FenceCalculator.new(total_length_ft: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:posts] > 0
    assert result[:rails] > 0
    assert result[:pickets] > 0
    assert result[:sections] > 0
  end

  test "100ft, 8ft spacing → 13 sections, 14 posts" do
    result = Construction::FenceCalculator.new(total_length_ft: 100, post_spacing_ft: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 13, result[:sections]
    assert_equal 14, result[:posts]
  end

  test "tall fence (>6ft) gets 3 rails per section" do
    result = Construction::FenceCalculator.new(total_length_ft: 100, height_ft: 8, post_spacing_ft: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    sections = result[:sections]
    assert_equal sections * 3, result[:rails]
  end

  test "standard fence (6ft) gets 2 rails per section" do
    result = Construction::FenceCalculator.new(total_length_ft: 100, height_ft: 6, post_spacing_ft: 10).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    sections = result[:sections]
    assert_equal sections * 2, result[:rails]
  end

  # --- Validation errors ---

  test "error when total length is zero" do
    result = Construction::FenceCalculator.new(total_length_ft: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Total length must be greater than zero"
  end

  test "error when height is zero" do
    result = Construction::FenceCalculator.new(total_length_ft: 100, height_ft: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Height must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::FenceCalculator.new(total_length_ft: 100)
    assert_equal [], calc.errors
  end
end
