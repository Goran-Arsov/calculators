require "test_helper"

class Construction::PaverCalculatorTest < ActiveSupport::TestCase
  test "standard 12x12 pavers on 10x10 patio" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 12, paver_width_in: 12,
      waste_pct: 0
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 100.0, result[:patio_area_sqft]
    assert_equal 100, result[:pavers_exact]
  end

  test "waste percent rounds up pavers" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 12, paver_width_in: 12,
      waste_pct: 10
    ).call
    assert_equal 110, result[:pavers_with_waste]
  end

  test "non-square pavers work" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 8, paver_width_in: 4,
      waste_pct: 0
    ).call
    # 8*4=32 sq in. 10x10=100 sq ft = 14400 sq in. 14400/32 = 450
    assert_equal 450, result[:pavers_exact]
  end

  test "base and sand computed for 4 in and 1 in depths" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 12, paver_width_in: 12
    ).call
    # 100 sq ft * (4/12) ft = 33.33 cu ft ÷ 27 = 1.23 cu yd
    assert_in_delta 1.23, result[:base_cubic_yards], 0.02
    # 100 * (1/12) / 27 ≈ 0.31
    assert_in_delta 0.31, result[:sand_cubic_yards], 0.02
  end

  test "error when patio length is zero" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 0, patio_width_ft: 10,
      paver_length_in: 12, paver_width_in: 12
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Patio length must be greater than zero"
  end

  test "error when paver size is zero" do
    result = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 0, paver_width_in: 12
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Paver length must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::PaverCalculator.new(
      patio_length_ft: 10, patio_width_ft: 10,
      paver_length_in: 12, paver_width_in: 12
    )
    assert_equal [], calc.errors
  end
end
