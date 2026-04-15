require "test_helper"

class Construction::ChimneyFlueCalculatorTest < ActiveSupport::TestCase
  test "60000 BTU/hr wood stove" do
    result = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "wood").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # area = 60000/30000 = 2 sq in → d = 2×√(2/π) ≈ 1.596 in (tiny — but rounds up to 6")
    assert_in_delta 2.0, result[:required_area_sqin], 0.01
    assert_equal 6, result[:commercial_round_in]
  end

  test "larger wood stove needs larger flue" do
    small = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "wood").call
    large = Construction::ChimneyFlueCalculator.new(btu_hr: 250_000, appliance: "wood").call
    assert large[:required_area_sqin] > small[:required_area_sqin]
  end

  test "gas appliance uses less flue area than wood" do
    wood = Construction::ChimneyFlueCalculator.new(btu_hr: 100_000, appliance: "wood").call
    gas = Construction::ChimneyFlueCalculator.new(btu_hr: 100_000, appliance: "gas").call
    assert gas[:required_area_sqin] < wood[:required_area_sqin]
  end

  test "minimum chimney height depends on appliance" do
    wood = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "wood").call
    gas = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "gas").call
    assert wood[:min_height_ft] > gas[:min_height_ft]
  end

  test "commercial round size rounds up to available size" do
    result = Construction::ChimneyFlueCalculator.new(btu_hr: 450_000, appliance: "wood").call
    # area = 15 sq in → d = 4.37 → round up to 6
    assert result[:commercial_round_in] >= result[:round_diameter_in]
  end

  test "error when BTU is zero" do
    result = Construction::ChimneyFlueCalculator.new(btu_hr: 0, appliance: "wood").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "BTU/hr must be greater than zero"
  end

  test "error for unknown appliance" do
    result = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "solar").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Appliance must be wood, gas, oil, or pellet"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ChimneyFlueCalculator.new(btu_hr: 60_000, appliance: "wood")
    assert_equal [], calc.errors
  end
end
