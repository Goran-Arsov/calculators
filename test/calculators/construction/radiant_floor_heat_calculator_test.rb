require "test_helper"

class Construction::RadiantFloorHeatCalculatorTest < ActiveSupport::TestCase
  test "200 sq ft tile at 12 OC" do
    result = Construction::RadiantFloorHeatCalculator.new(
      area_sqft: 200, spacing_in: 12, surface: "tile", tube_size: "1/2"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 1.0 × 200 × 1.10 = 220 ft of tube
    assert_equal 220, result[:total_tube_ft]
    # 200 × 27 = 5400 BTU/hr
    assert_equal 5400, result[:total_btu_hr]
  end

  test "tighter spacing means more tube" do
    loose = Construction::RadiantFloorHeatCalculator.new(area_sqft: 200, spacing_in: 12).call
    tight = Construction::RadiantFloorHeatCalculator.new(area_sqft: 200, spacing_in: 6).call
    assert tight[:total_tube_ft] > loose[:total_tube_ft]
  end

  test "multiple loops for large area" do
    # 500 sq ft × 2.0 × 1.10 = 1100 ft; 1/2" limit 300 → 4 loops
    result = Construction::RadiantFloorHeatCalculator.new(
      area_sqft: 500, spacing_in: 6, tube_size: "1/2"
    ).call
    assert_equal 4, result[:loop_count]
  end

  test "carpet has much lower output than concrete" do
    concrete = Construction::RadiantFloorHeatCalculator.new(area_sqft: 100, surface: "concrete").call
    carpet = Construction::RadiantFloorHeatCalculator.new(area_sqft: 100, surface: "carpet").call
    assert concrete[:total_btu_hr] > carpet[:total_btu_hr] * 2
  end

  test "BTU to watts conversion" do
    result = Construction::RadiantFloorHeatCalculator.new(area_sqft: 100, surface: "tile").call
    assert_in_delta result[:total_btu_hr] / 3.412, result[:total_watts], 1.0
  end

  test "larger tube allows longer loops" do
    half = Construction::RadiantFloorHeatCalculator.new(area_sqft: 400, spacing_in: 6, tube_size: "1/2").call
    bigger = Construction::RadiantFloorHeatCalculator.new(area_sqft: 400, spacing_in: 6, tube_size: "5/8").call
    assert bigger[:loop_count] <= half[:loop_count]
  end

  test "error when area is zero" do
    result = Construction::RadiantFloorHeatCalculator.new(area_sqft: 0, surface: "tile").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Floor area must be greater than zero"
  end

  test "error for invalid spacing" do
    result = Construction::RadiantFloorHeatCalculator.new(area_sqft: 100, spacing_in: 18, surface: "tile").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Spacing must be 6, 9, or 12 inches"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RadiantFloorHeatCalculator.new(area_sqft: 100, surface: "tile")
    assert_equal [], calc.errors
  end
end
