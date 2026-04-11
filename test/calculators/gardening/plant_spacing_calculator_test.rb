require "test_helper"

class Gardening::PlantSpacingCalculatorTest < ActiveSupport::TestCase
  test "8x4 bed at 12 inch square spacing fits 45 plants" do
    result = Gardening::PlantSpacingCalculator.new(
      length_ft: 8, width_ft: 4, spacing_in: 12, pattern: "square"
    ).call
    assert_equal true, result[:valid]
    # 96/12 + 1 = 9 per row, 48/12 + 1 = 5 rows → 45 plants
    assert_equal 45, result[:plants]
    assert_equal 9, result[:plants_per_row]
    assert_equal 5, result[:rows]
  end

  test "triangular fits more plants than square on larger beds" do
    sq = Gardening::PlantSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12, pattern: "square"
    ).call
    tri = Gardening::PlantSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12, pattern: "triangular"
    ).call
    assert tri[:plants] > sq[:plants]
  end

  test "invalid pattern errors" do
    result = Gardening::PlantSpacingCalculator.new(
      length_ft: 8, width_ft: 4, spacing_in: 12, pattern: "hex"
    ).call
    assert_equal false, result[:valid]
  end

  test "zero spacing errors" do
    result = Gardening::PlantSpacingCalculator.new(
      length_ft: 8, width_ft: 4, spacing_in: 0
    ).call
    assert_equal false, result[:valid]
  end
end
