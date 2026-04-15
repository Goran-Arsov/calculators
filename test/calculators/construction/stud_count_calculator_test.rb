require "test_helper"

class Construction::StudCountCalculatorTest < ActiveSupport::TestCase
  test "20 ft wall at 16 OC with no corners or openings" do
    result = Construction::StudCountCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, spacing_in: 16, corners: 0, openings: 0
    ).call
    assert_equal true, result[:valid]
    # 240 in / 16 = 15, ceil = 15, + 1 = 16 field studs
    assert_equal 16, result[:field_studs]
    assert_equal 16, result[:total_studs]
  end

  test "corners add 2 studs each" do
    result = Construction::StudCountCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, corners: 2, openings: 0
    ).call
    # 16 field + (2 corners × 2) = 20
    assert_equal 20, result[:total_studs]
    assert_equal 4, result[:corner_studs]
  end

  test "openings add 4 studs each (2 jack + 2 king)" do
    result = Construction::StudCountCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, corners: 0, openings: 3
    ).call
    # 16 field + 12 opening
    assert_equal 28, result[:total_studs]
    assert_equal 12, result[:opening_studs]
  end

  test "plate linear feet is 3x wall length" do
    result = Construction::StudCountCalculator.new(wall_length_ft: 20, wall_height_ft: 8).call
    assert_in_delta 60.0, result[:plate_linear_ft], 0.01
  end

  test "24 inch spacing uses fewer studs" do
    result16 = Construction::StudCountCalculator.new(wall_length_ft: 20, wall_height_ft: 8, spacing_in: 16).call
    result24 = Construction::StudCountCalculator.new(wall_length_ft: 20, wall_height_ft: 8, spacing_in: 24).call
    assert result24[:field_studs] < result16[:field_studs]
  end

  test "stud stock linear feet equals studs times height" do
    result = Construction::StudCountCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, corners: 0, openings: 0
    ).call
    # 16 studs × 8 ft = 128 linear ft
    assert_in_delta 128.0, result[:stud_stock_linear_ft], 0.01
  end

  test "error for invalid spacing" do
    result = Construction::StudCountCalculator.new(
      wall_length_ft: 20, wall_height_ft: 8, spacing_in: 15
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Spacing must be 12, 16, 19.2, or 24 inches"
  end

  test "error when wall length is zero" do
    result = Construction::StudCountCalculator.new(wall_length_ft: 0, wall_height_ft: 8).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall length must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::StudCountCalculator.new(wall_length_ft: 20, wall_height_ft: 8)
    assert_equal [], calc.errors
  end
end
