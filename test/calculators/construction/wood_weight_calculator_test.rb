require "test_helper"

class Construction::WoodWeightCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "red oak 2x6x8 single piece" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "Red Oak", result[:species_name]
    assert_equal 44.0, result[:density_lb_ft3]
    # Volume = (2 * 6 * 96) / 1728 = 0.6666...
    assert_equal 0.6667, result[:volume_ft3_per_piece]
    # Weight = 0.6666... * 44 = 29.333... rounds to 29.33
    assert_equal 29.33, result[:weight_lb_per_piece]
    assert_equal 29.33, result[:total_weight_lb]
  end

  test "quantity multiplies total weight and volume" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8,
      quantity: 10
    ).call

    assert_equal true, result[:valid]
    # 10 pieces
    assert_equal 293.33, result[:total_weight_lb]
    assert_in_delta 6.6667, result[:total_volume_ft3], 0.001
  end

  test "kg conversion is applied" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    # Unrounded weight_lb = (2*6*96/1728) * 44 = 29.333...
    # kg = 29.333... * 0.453592 = 13.3054... rounds to 13.31
    expected_kg = ((2 * 6 * 96.0 / 1728) * 44 * 0.453592).round(2)
    assert_equal expected_kg, result[:total_weight_kg]
  end

  test "density_kg_m3 is converted from lb_ft3" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    expected = (44.0 * 16.0185).round(2)
    assert_equal expected, result[:density_kg_m3]
  end

  test "ipe is heavier than poplar for the same dimensions" do
    ipe = Construction::WoodWeightCalculator.new(
      species: "ipe",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    poplar = Construction::WoodWeightCalculator.new(
      species: "poplar",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    assert_equal true, ipe[:valid]
    assert_equal true, poplar[:valid]
    assert ipe[:total_weight_lb] > poplar[:total_weight_lb]
  end

  test "1x12x1 cubic foot gives density weight" do
    # 1" x 12" x 1' = exactly 1/12 ft3 in wood.
    # Actually: (1 * 12 * 12) / 1728 = 144/1728 = 0.0833 ft3
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 1,
      width_in: 12,
      length_ft: 1
    ).call

    assert_equal true, result[:valid]
    assert_equal 0.0833, result[:volume_ft3_per_piece]
    # 0.0833... * 44 = 3.666...
    assert_equal 3.67, result[:weight_lb_per_piece]
  end

  test "string inputs are coerced" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: "2",
      width_in: "6",
      length_ft: "8",
      quantity: "3"
    ).call

    assert_equal true, result[:valid]
    assert_equal 88.0, result[:total_weight_lb].round(0)
  end

  test "species density table contains expected entries" do
    assert Construction::WoodWeightCalculator::SPECIES_DENSITY.key?("red_oak")
    assert Construction::WoodWeightCalculator::SPECIES_DENSITY.key?("ipe")
    assert_equal 44.0, Construction::WoodWeightCalculator::SPECIES_DENSITY["red_oak"][:density_lb_ft3]
    assert_equal 69.0, Construction::WoodWeightCalculator::SPECIES_DENSITY["ipe"][:density_lb_ft3]
  end

  # --- Validation errors ---

  test "error when species is unknown" do
    result = Construction::WoodWeightCalculator.new(
      species: "unobtainium",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Unknown species"
  end

  test "error when thickness is zero" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 0,
      width_in: 6,
      length_ft: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Thickness must be greater than zero"
  end

  test "error when width is zero" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 0,
      length_ft: 8
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Width must be greater than zero"
  end

  test "error when length is zero" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 0
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when quantity is zero" do
    result = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8,
      quantity: 0
    ).call

    assert_equal false, result[:valid]
    assert_includes result[:errors], "Quantity must be at least 1"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::WoodWeightCalculator.new(
      species: "red_oak",
      thickness_in: 2,
      width_in: 6,
      length_ft: 8
    )
    assert_equal [], calc.errors
  end
end
