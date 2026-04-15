require "test_helper"

class Construction::SnowMeltBtuCalculatorTest < ActiveSupport::TestCase
  test "1000 sqft moderate climate" do
    result = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000, climate: "moderate").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 1000 × 125 = 125,000 surface + 15% back loss = 143,750
    assert_equal 125, result[:btu_per_sqft]
    assert_equal 125_000, result[:surface_btu_hr]
    assert_equal 143_750, result[:total_btu_hr]
  end

  test "colder climate needs more BTU" do
    mild = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000, climate: "mild").call
    severe = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000, climate: "severe").call
    assert severe[:total_btu_hr] > mild[:total_btu_hr] * 1.5
  end

  test "boiler input includes efficiency" do
    result = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000, climate: "moderate").call
    assert result[:boiler_input_btu_hr] > result[:total_btu_hr]
  end

  test "BTU to watts conversion" do
    result = Construction::SnowMeltBtuCalculator.new(area_sqft: 500).call
    assert_in_delta result[:total_btu_hr] / 3.412, result[:total_watts], 1.0
  end

  test "larger area scales linearly" do
    small = Construction::SnowMeltBtuCalculator.new(area_sqft: 500).call
    big = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000).call
    assert_in_delta small[:total_btu_hr] * 2, big[:total_btu_hr], 1
  end

  test "error when area is zero" do
    result = Construction::SnowMeltBtuCalculator.new(area_sqft: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Area must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::SnowMeltBtuCalculator.new(area_sqft: 1000)
    assert_equal [], calc.errors
  end
end
