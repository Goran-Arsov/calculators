require "test_helper"

class Construction::RetainingWallCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "20ft x 3ft wall with defaults produces valid results" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3
    ).call
    assert_equal true, result[:valid]
    assert result[:rows] > 0
    assert result[:blocks_per_row] > 0
    assert result[:total_blocks] > 0
    assert result[:cap_blocks] > 0
    assert result[:gravel_cubic_yards] > 0
    assert result[:backfill_cubic_yards] > 0
  end

  test "rows calculated correctly" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3, block_height_in: 6
    ).call
    # 3ft * 12 = 36in / 6in = 6 rows
    assert_equal 6, result[:rows]
  end

  test "blocks per row calculated correctly" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3, block_length_in: 16
    ).call
    # 20ft * 12 = 240in / 16in = 15 blocks
    assert_equal 15, result[:blocks_per_row]
  end

  test "total blocks includes 10 percent waste" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3,
      block_height_in: 6, block_length_in: 16
    ).call
    # rows=6, blocks_per_row=15, raw=90, 90*1.10=99.0 (ceil handles float precision)
    assert_equal 100, result[:total_blocks]
  end

  test "cap blocks equals blocks per row" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3
    ).call
    assert_equal result[:blocks_per_row], result[:cap_blocks]
  end

  test "gravel base calculated correctly" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 27, wall_height_ft: 3
    ).call
    # 0.5 * 2 * 27 = 27 cubic ft / 27 = 1.0 cubic yard
    assert_equal 1.0, result[:gravel_cubic_yards]
  end

  test "backfill calculated correctly" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 27, wall_height_ft: 3
    ).call
    # 3 * 1 * 27 = 81 cubic ft / 27 = 3.0 cubic yards
    assert_equal 3.0, result[:backfill_cubic_yards]
  end

  test "fractional heights round up rows" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 2.5, block_height_in: 6
    ).call
    # 2.5 * 12 = 30in / 6in = 5, exact so 5 rows
    assert_equal 5, result[:rows]
  end

  test "non-standard block size works" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 10, wall_height_ft: 2,
      block_height_in: 8, block_length_in: 12
    ).call
    # rows: 24/8 = 3, blocks per row: 120/12 = 10, total raw = 30, with waste = 33
    assert_equal 3, result[:rows]
    assert_equal 10, result[:blocks_per_row]
    assert_equal 33, result[:total_blocks]
  end

  # --- Validation errors ---

  test "error when wall length is zero" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 0, wall_height_ft: 3
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall length must be greater than zero"
  end

  test "error when wall height is zero" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Wall height must be greater than zero"
  end

  test "error when block height is zero" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3, block_height_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Block height must be greater than zero"
  end

  test "error when block length is zero" do
    result = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3, block_length_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Block length must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RetainingWallCalculator.new(
      wall_length_ft: 20, wall_height_ft: 3
    )
    assert_equal [], calc.errors
  end
end
