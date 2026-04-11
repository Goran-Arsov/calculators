require "test_helper"

class Construction::GroutCalculatorTest < ActiveSupport::TestCase
  test "12x12 tile, 1/8 joint, 1/4 depth, 100 sqft" do
    result = Construction::GroutCalculator.new(
      area_sqft: 100, tile_length_in: 12, tile_width_in: 12,
      joint_width_in: 0.125, tile_thickness_in: 0.25, waste_pct: 10
    ).call
    assert_equal true, result[:valid]
    # (24/144) * 0.125 * 0.25 * 45 = 0.234 lb/sqft; with 10% waste ≈ 25.8 lb
    assert_in_delta 0.234, result[:lbs_per_sqft], 0.01
    assert_in_delta 25.8, result[:pounds_needed], 0.5
    assert_equal 2, result[:bags_25lb]
  end

  test "wider joint doubles the grout" do
    narrow = Construction::GroutCalculator.new(
      area_sqft: 100, tile_length_in: 12, tile_width_in: 12,
      joint_width_in: 0.125, tile_thickness_in: 0.25
    ).call
    wide = Construction::GroutCalculator.new(
      area_sqft: 100, tile_length_in: 12, tile_width_in: 12,
      joint_width_in: 0.25, tile_thickness_in: 0.25
    ).call
    assert_in_delta narrow[:pounds_needed] * 2, wide[:pounds_needed], 0.1
  end

  test "zero area returns error" do
    result = Construction::GroutCalculator.new(
      area_sqft: 0, tile_length_in: 12, tile_width_in: 12,
      joint_width_in: 0.125
    ).call
    assert_equal false, result[:valid]
  end

  test "zero tile size returns error" do
    result = Construction::GroutCalculator.new(
      area_sqft: 100, tile_length_in: 0, tile_width_in: 12,
      joint_width_in: 0.125
    ).call
    assert_equal false, result[:valid]
  end
end
