require "test_helper"

class Construction::RebarSpacingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "20x20 slab with defaults produces valid results" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20
    ).call
    assert_equal true, result[:valid]
    assert result[:total_bars] > 0
    assert result[:total_linear_ft] > 0
    assert result[:total_weight_lbs] > 0
    assert result[:sticks_20ft] > 0
  end

  test "bars along length calculated correctly" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    # Bars along length = floor(20*12/12) + 1 = 20 + 1 = 21
    assert_equal 21, result[:bars_along_length]
  end

  test "bars along width calculated correctly" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    # Bars along width = floor(20*12/12) + 1 = 20 + 1 = 21
    assert_equal 21, result[:bars_along_width]
  end

  test "total bars is sum of both directions" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    assert_equal result[:bars_along_length] + result[:bars_along_width], result[:total_bars]
  end

  test "linear feet includes 10% waste" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    # bars_along_length = 21, each 20ft = 420ft
    # bars_along_width = 21, each 20ft = 420ft
    # raw = 840ft, with 10% waste = 924.0
    assert_equal 924.0, result[:total_linear_ft]
  end

  test "weight calculated with bar weight per foot" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12, bar_size: "#4"
    ).call
    expected_weight = (result[:total_linear_ft] * 0.668).round(1)
    assert_equal expected_weight, result[:total_weight_lbs]
  end

  test "sticks_20ft calculated correctly" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    expected_sticks = (result[:total_linear_ft] / 20.0).ceil
    assert_equal expected_sticks, result[:sticks_20ft]
  end

  test "18-inch spacing produces fewer bars" do
    result_12 = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 12
    ).call
    result_18 = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 18
    ).call
    assert result_12[:total_bars] > result_18[:total_bars]
  end

  test "larger bar size produces heavier result" do
    result_4 = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, bar_size: "#4"
    ).call
    result_6 = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, bar_size: "#6"
    ).call
    assert result_6[:total_weight_lbs] > result_4[:total_weight_lbs]
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 0, width_ft: 20
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when width is zero" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Width must be greater than zero"
  end

  test "error when spacing is zero" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, spacing_in: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Spacing must be greater than zero"
  end

  test "error when bar size is invalid" do
    result = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20, bar_size: "#99"
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid bar size (use #3 through #8)"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RebarSpacingCalculator.new(
      length_ft: 20, width_ft: 20
    )
    assert_equal [], calc.errors
  end
end
