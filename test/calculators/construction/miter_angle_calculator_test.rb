require "test_helper"

class Construction::MiterAngleCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "square (4 sides) gives 45° miter angle" do
    result = Construction::MiterAngleCalculator.new(sides: 4).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4, result[:sides]
    assert_equal 90.0, result[:interior_angle]
    assert_equal 45.0, result[:miter_angle]
    assert_equal 90.0, result[:full_corner_angle]
  end

  test "triangle (3 sides) gives 60° miter angle" do
    result = Construction::MiterAngleCalculator.new(sides: 3).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 60.0, result[:interior_angle]
    assert_equal 60.0, result[:miter_angle]
    assert_equal 120.0, result[:full_corner_angle]
  end

  test "hexagon (6 sides) gives 30° miter angle" do
    result = Construction::MiterAngleCalculator.new(sides: 6).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 120.0, result[:interior_angle]
    assert_equal 30.0, result[:miter_angle]
    assert_equal 60.0, result[:full_corner_angle]
  end

  test "octagon (8 sides) gives 22.5° miter angle" do
    result = Construction::MiterAngleCalculator.new(sides: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 135.0, result[:interior_angle]
    assert_equal 22.5, result[:miter_angle]
    assert_equal 45.0, result[:full_corner_angle]
  end

  test "pentagon (5 sides) gives 36° miter angle" do
    result = Construction::MiterAngleCalculator.new(sides: 5).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 108.0, result[:interior_angle]
    assert_equal 36.0, result[:miter_angle]
    assert_equal 72.0, result[:full_corner_angle]
  end

  test "max sides (100) still valid" do
    result = Construction::MiterAngleCalculator.new(sides: 100).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1.8, result[:miter_angle]
  end

  test "string input is coerced to integer" do
    result = Construction::MiterAngleCalculator.new(sides: "4").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 4, result[:sides]
    assert_equal 45.0, result[:miter_angle]
  end

  test "values rounded to 4 decimals" do
    result = Construction::MiterAngleCalculator.new(sides: 7).call
    assert_equal true, result[:valid]
    # 180 / 7 = 25.7142857...
    assert_equal 25.7143, result[:miter_angle]
    # 360 / 7 = 51.4285714...
    assert_equal 51.4286, result[:full_corner_angle]
  end

  # --- Validation errors ---

  test "error when sides is less than 3" do
    result = Construction::MiterAngleCalculator.new(sides: 2).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of sides must be at least 3"
  end

  test "error when sides is zero" do
    result = Construction::MiterAngleCalculator.new(sides: 0).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of sides must be at least 3"
  end

  test "error when sides is negative" do
    result = Construction::MiterAngleCalculator.new(sides: -4).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of sides must be at least 3"
  end

  test "error when sides exceeds 100" do
    result = Construction::MiterAngleCalculator.new(sides: 101).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Number of sides must be 100 or fewer"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::MiterAngleCalculator.new(sides: 4)
    assert_equal [], calc.errors
  end
end
