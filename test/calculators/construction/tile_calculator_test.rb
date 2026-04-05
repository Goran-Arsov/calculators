require "test_helper"

class Construction::TileCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "100 sqft, 12x12 tiles → tiles > 0" do
    result = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12).call
    assert_nil result[:errors]
    assert result[:tiles_needed] > 0
    assert result[:grout_lbs] > 0
    assert result[:adhesive_bags] > 0
  end

  test "tile count with no waste and no grout matches expected" do
    # 100 sqft / (12*12/144) sqft per tile = 100 tiles
    result = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, grout_width_in: 0, waste_pct: 0).call
    assert_nil result[:errors]
    assert_equal 100, result[:tiles_needed]
  end

  test "waste percentage increases tile count" do
    no_waste = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, waste_pct: 0).call
    with_waste = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, waste_pct: 15).call
    assert with_waste[:tiles_needed] > no_waste[:tiles_needed]
  end

  test "grout width affects tile count" do
    no_grout = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, grout_width_in: 0, waste_pct: 0).call
    wide_grout = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, grout_width_in: 0.25, waste_pct: 0).call
    # Wider grout → larger effective tile footprint → fewer tiles needed to cover the area
    assert wide_grout[:tiles_needed] <= no_grout[:tiles_needed]
  end

  test "adhesive bags scale with area" do
    small = Construction::TileCalculator.new(area_sqft: 50, tile_length_in: 12, tile_width_in: 12).call
    large = Construction::TileCalculator.new(area_sqft: 200, tile_length_in: 12, tile_width_in: 12).call
    assert large[:adhesive_bags] > small[:adhesive_bags]
  end

  test "area_with_waste returned correctly" do
    result = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, waste_pct: 10).call
    assert_nil result[:errors]
    assert_equal 110.0, result[:area_with_waste]
  end

  test "rectangular tiles calculated correctly" do
    # 6x24 subway tile = 144 sq in = 1 sqft each
    result = Construction::TileCalculator.new(area_sqft: 50, tile_length_in: 24, tile_width_in: 6, grout_width_in: 0, waste_pct: 0).call
    assert_nil result[:errors]
    assert_equal 50, result[:tiles_needed]
  end

  test "string inputs are coerced" do
    result = Construction::TileCalculator.new(area_sqft: "100", tile_length_in: "12", tile_width_in: "12", grout_width_in: "0.125", waste_pct: "10").call
    assert_nil result[:errors]
    assert result[:tiles_needed] > 0
  end

  # --- Validation errors ---

  test "error when area is zero" do
    result = Construction::TileCalculator.new(area_sqft: 0, tile_length_in: 12, tile_width_in: 12).call
    assert result[:errors].any?
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "error when tile length is zero" do
    result = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 0, tile_width_in: 12).call
    assert result[:errors].any?
    assert_includes result[:errors], "Tile length must be greater than zero"
  end

  test "error when waste is negative" do
    result = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12, waste_pct: -5).call
    assert result[:errors].any?
    assert_includes result[:errors], "Waste percentage cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::TileCalculator.new(area_sqft: 100, tile_length_in: 12, tile_width_in: 12)
    assert_equal [], calc.errors
  end
end
