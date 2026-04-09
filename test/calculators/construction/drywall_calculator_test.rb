require "test_helper"

class Construction::DrywallCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12x10x8 room with defaults produces valid results" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8
    ).call
    assert_equal true, result[:valid]
    assert result[:sheets_needed] > 0
    assert result[:total_wall_area_sqft] > 0
    assert result[:net_area_sqft] > 0
    assert result[:joint_compound_gallons] > 0
    assert result[:tape_rolls] > 0
  end

  test "wall area calculated correctly" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 10, room_width_ft: 10, room_height_ft: 10,
      num_doors: 0, num_windows: 0
    ).call
    # Perimeter = 2*(10+10) = 40, Wall area = 40*10 = 400
    assert_equal 400.0, result[:total_wall_area_sqft]
    assert_equal 400.0, result[:net_area_sqft]
  end

  test "doors and windows reduce net area" do
    result_no_openings = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8,
      num_doors: 0, num_windows: 0
    ).call
    result_with_openings = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8,
      num_doors: 2, num_windows: 3
    ).call
    assert result_with_openings[:net_area_sqft] < result_no_openings[:net_area_sqft]
  end

  test "larger sheet size requires fewer sheets" do
    result_4x8 = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8,
      num_doors: 0, num_windows: 0, sheet_size: 32
    ).call
    result_4x12 = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8,
      num_doors: 0, num_windows: 0, sheet_size: 48
    ).call
    assert result_4x12[:sheets_needed] < result_4x8[:sheets_needed]
  end

  test "waste factor included in sheet count" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 10, room_width_ft: 10, room_height_ft: 10,
      num_doors: 0, num_windows: 0, sheet_size: 32
    ).call
    # Net area = 400, 400/32 = 12.5, with 10% waste = 13.75, ceil = 14
    assert_equal 14, result[:sheets_needed]
  end

  test "joint compound calculation" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 10, room_width_ft: 10, room_height_ft: 10,
      num_doors: 0, num_windows: 0
    ).call
    # 400 sqft / 100 = 4 gallons
    assert_equal 4, result[:joint_compound_gallons]
  end

  test "tape roll calculation" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 10, room_width_ft: 10, room_height_ft: 10,
      num_doors: 0, num_windows: 0
    ).call
    # 400 sqft / 50 = 8 rolls
    assert_equal 8, result[:tape_rolls]
  end

  test "net area does not go negative" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 5, room_width_ft: 5, room_height_ft: 8,
      num_doors: 10, num_windows: 10
    ).call
    assert_equal true, result[:valid]
    assert_equal 0, result[:net_area_sqft]
    assert_equal 0, result[:sheets_needed]
  end

  # --- Validation errors ---

  test "error when room length is zero" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 0, room_width_ft: 10, room_height_ft: 8
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Room length must be greater than zero"
  end

  test "error when room width is zero" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 0, room_height_ft: 8
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Room width must be greater than zero"
  end

  test "error when room height is zero" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Room height must be greater than zero"
  end

  test "error when sheet size is invalid" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8, sheet_size: 50
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Sheet size must be 32 or 48 sq ft"
  end

  test "error when doors negative" do
    result = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8, num_doors: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Number of doors cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DrywallCalculator.new(
      room_length_ft: 12, room_width_ft: 10, room_height_ft: 8
    )
    assert_equal [], calc.errors
  end
end
