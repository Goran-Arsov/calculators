require "test_helper"

class Textile::CrossStitchFabricCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "100x100 design on Aida 14 with 3in margin" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 100, count: 14, margin_in: 3, stitches_over: 1
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 100 / 14 = 7.143 in
    assert_equal 7.143, result[:design_width_in]
    assert_equal 7.143, result[:design_height_in]
    # + 2*3 = 13.14 in
    assert_equal 13.14, result[:fabric_width_in]
    assert_equal 13.14, result[:fabric_height_in]
    assert_equal 10000, result[:total_stitches]
  end

  test "Aida 14 with effective count equals actual count when stitches_over is 1" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 140, design_height_st: 140, count: 14, margin_in: 0, stitches_over: 1
    ).call
    assert_equal 14.0, result[:effective_count]
    # 140 / 14 = 10
    assert_equal 10.0, result[:design_width_in]
    assert_equal 10.0, result[:design_height_in]
  end

  test "evenweave 28 stitched over 2 acts like Aida 14" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 140, design_height_st: 140, count: 28, margin_in: 0, stitches_over: 2
    ).call
    assert_equal 14.0, result[:effective_count]
    assert_equal 10.0, result[:design_width_in]
    assert_equal 10.0, result[:design_height_in]
  end

  test "metric conversion" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 140, design_height_st: 140, count: 14, margin_in: 0
    ).call
    # 10 in * 2.54 = 25.4 cm
    assert_equal 25.4, result[:design_width_cm]
    assert_equal 25.4, result[:design_height_cm]
  end

  test "total stitches multiplied correctly" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 200, design_height_st: 150, count: 14
    ).call
    assert_equal 30000, result[:total_stitches]
  end

  test "all_counts returns comparison table for every fabric count" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 140, design_height_st: 140, count: 14, margin_in: 0
    ).call
    assert_equal Textile::CrossStitchFabricCalculator::FABRIC_COUNTS.length, result[:all_counts].length
    aida_14 = result[:all_counts].find { |c| c[:count] == 14 }
    assert_equal 10.0, aida_14[:fabric_width_in]
    aida_11 = result[:all_counts].find { |c| c[:count] == 11 }
    # 140 / 11 ≈ 12.73
    assert_equal 12.73, aida_11[:fabric_width_in]
  end

  test "FABRIC_COUNTS constant is accessible and has expected counts" do
    assert Textile::CrossStitchFabricCalculator::FABRIC_COUNTS.is_a?(Array)
    counts = Textile::CrossStitchFabricCalculator::FABRIC_COUNTS.map { |e| e[:count] }
    assert_includes counts, 11
    assert_includes counts, 14
    assert_includes counts, 18
    assert_includes counts, 22
    assert_includes counts, 28
    assert_includes counts, 40
  end

  test "zero margin gives fabric same size as design" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 140, design_height_st: 140, count: 14, margin_in: 0
    ).call
    assert_equal result[:design_width_in], result[:fabric_width_in]
    assert_equal result[:design_height_in], result[:fabric_height_in]
  end

  test "string inputs are coerced" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: "100", design_height_st: "100", count: "14", margin_in: "3", stitches_over: "1"
    ).call
    assert_equal true, result[:valid]
    assert_equal 10000, result[:total_stitches]
  end

  # --- Validation errors ---

  test "error when design width is zero" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 0, design_height_st: 100, count: 14
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Design width must be greater than zero"
  end

  test "error when design height is zero" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 0, count: 14
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Design height must be greater than zero"
  end

  test "error when count is zero" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 100, count: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Fabric count must be greater than zero"
  end

  test "error when margin is negative" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 100, count: 14, margin_in: -1
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Margin cannot be negative"
  end

  test "error when stitches_over is zero" do
    result = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 100, count: 14, stitches_over: 0
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Stitches over must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Textile::CrossStitchFabricCalculator.new(
      design_width_st: 100, design_height_st: 100, count: 14
    )
    assert_equal [], calc.errors
  end
end
