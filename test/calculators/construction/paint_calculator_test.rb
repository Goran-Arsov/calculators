require "test_helper"

class Construction::PaintCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12x10x8 room, 2 coats → gallons > 0" do
    result = Construction::PaintCalculator.new(length: 12, width: 10, height: 8, coats: 2).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:gallons] > 0
    assert result[:wall_area] > 0
    assert result[:paintable_area] > 0
  end

  test "wall area calculated correctly" do
    result = Construction::PaintCalculator.new(
      length: 10, width: 10, height: 10, coats: 1, doors: 0, windows: 0
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 2 * (10 + 10) * 10 = 400 sqft
    assert_equal 400.0, result[:wall_area]
    assert_equal 400.0, result[:paintable_area]
  end

  test "doors and windows reduce paintable area" do
    result_no_openings = Construction::PaintCalculator.new(
      length: 12, width: 10, height: 8, coats: 1, doors: 0, windows: 0
    ).call
    result_with_openings = Construction::PaintCalculator.new(
      length: 12, width: 10, height: 8, coats: 1, doors: 2, windows: 3
    ).call
    assert result_with_openings[:paintable_area] < result_no_openings[:paintable_area]
  end

  test "more coats require more gallons" do
    result_1_coat = Construction::PaintCalculator.new(
      length: 12, width: 10, height: 8, coats: 1, doors: 0, windows: 0
    ).call
    result_3_coats = Construction::PaintCalculator.new(
      length: 12, width: 10, height: 8, coats: 3, doors: 0, windows: 0
    ).call
    assert result_3_coats[:gallons] > result_1_coat[:gallons]
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::PaintCalculator.new(length: 0, width: 10, height: 8).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when coats is zero" do
    result = Construction::PaintCalculator.new(length: 12, width: 10, height: 8, coats: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Coats must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PaintCalculator.new(length: 12, width: 10, height: 8)
    assert_equal [], calc.errors
  end
end
