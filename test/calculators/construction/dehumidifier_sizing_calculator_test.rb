require "test_helper"

class Construction::DehumidifierSizingCalculatorTest < ActiveSupport::TestCase
  test "500 sqft very damp uses table value" do
    result = Construction::DehumidifierSizingCalculator.new(
      floor_area_sqft: 500, condition: "very_damp"
    ).call
    assert_equal true, result[:valid]
    assert_equal 12, result[:pints_per_day]
  end

  test "larger area needs more pints" do
    small = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 500, condition: "very_damp").call
    large = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 2000, condition: "very_damp").call
    assert large[:pints_per_day] > small[:pints_per_day]
  end

  test "more severe condition needs more pints" do
    mod = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1500, condition: "moderate").call
    ext = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1500, condition: "extreme").call
    assert ext[:pints_per_day] > mod[:pints_per_day]
  end

  test "interpolates between table rows" do
    # 750 sq ft is halfway between 500 and 1000
    r500 = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 500, condition: "very_damp").call
    r750 = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 750, condition: "very_damp").call
    r1000 = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1000, condition: "very_damp").call
    assert r750[:pints_per_day] > r500[:pints_per_day]
    assert r750[:pints_per_day] < r1000[:pints_per_day]
  end

  test "liters per day conversion" do
    result = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1000, condition: "wet").call
    # 20 pints × 0.473176 ≈ 9.46 L
    assert_in_delta 9.46, result[:liters_per_day], 0.05
  end

  test "category label assignment" do
    small = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 500, condition: "moderate").call
    big = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 3000, condition: "extreme").call
    assert small[:category].length > 0
    assert big[:category].length > 0
  end

  test "error when area is zero" do
    result = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Floor area must be greater than zero"
  end

  test "error for invalid condition" do
    result = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1000, condition: "typhoon").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Condition must be moderate, very_damp, wet, or extreme"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::DehumidifierSizingCalculator.new(floor_area_sqft: 1000)
    assert_equal [], calc.errors
  end
end
