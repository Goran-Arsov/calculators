require "test_helper"

class Construction::ErvHrvVentilationCalculatorTest < ActiveSupport::TestCase
  test "2000 sqft 3 bedroom house" do
    result = Construction::ErvHrvVentilationCalculator.new(
      floor_area_sqft: 2000, bedrooms: 3
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 0.03 × 2000 + 7.5 × (3+1) = 60 + 30 = 90 CFM
    assert_in_delta 90.0, result[:total_required_cfm], 0.01
    assert_in_delta 90.0, result[:mechanical_cfm], 0.01
  end

  test "larger house needs more CFM" do
    small = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 1500, bedrooms: 2).call
    large = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 3500, bedrooms: 4).call
    assert large[:total_required_cfm] > small[:total_required_cfm]
  end

  test "more bedrooms adds 7.5 CFM each" do
    b2 = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 2).call
    b3 = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 3).call
    assert_in_delta 7.5, b3[:total_required_cfm] - b2[:total_required_cfm], 0.01
  end

  test "infiltration credit reduces mechanical CFM" do
    tight = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 3, ach50: 2, volume_cuft: 16000).call
    leaky = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 3, ach50: 8, volume_cuft: 16000).call
    assert leaky[:mechanical_cfm] < tight[:mechanical_cfm]
  end

  test "mechanical never goes below zero" do
    result = Construction::ErvHrvVentilationCalculator.new(
      floor_area_sqft: 1000, bedrooms: 1, ach50: 20, volume_cuft: 10000
    ).call
    assert result[:mechanical_cfm] >= 0
  end

  test "error when floor area is zero" do
    result = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 0, bedrooms: 3).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Floor area must be greater than zero"
  end

  test "error when ACH50 given without volume" do
    result = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 3, ach50: 5).call
    assert_equal false, result[:valid]
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ErvHrvVentilationCalculator.new(floor_area_sqft: 2000, bedrooms: 3)
    assert_equal [], calc.errors
  end
end
