require "test_helper"

class Construction::AsphaltCalculatorTest < ActiveSupport::TestCase
  test "standard driveway returns positive tonnage" do
    result = Construction::AsphaltCalculator.new(length_ft: 50, width_ft: 12, depth_in: 3).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:us_tons] > 0
    assert result[:cubic_feet] > 0
  end

  test "50x12x3 inches computes expected volume" do
    result = Construction::AsphaltCalculator.new(length_ft: 50, width_ft: 12, depth_in: 3).call
    # 50 * 12 * 0.25 ft = 150 cu ft
    assert_in_delta 150.0, result[:cubic_feet], 0.01
    # 150 * 145 lb = 21,750 lb → 10.875 US tons
    assert_in_delta 10.88, result[:us_tons], 0.01
  end

  test "uses custom density when provided" do
    default = Construction::AsphaltCalculator.new(length_ft: 10, width_ft: 10, depth_in: 4).call
    custom  = Construction::AsphaltCalculator.new(length_ft: 10, width_ft: 10, depth_in: 4, density_lb_per_cuft: 120).call
    assert custom[:us_tons] < default[:us_tons]
  end

  test "truckloads rounds up" do
    result = Construction::AsphaltCalculator.new(length_ft: 50, width_ft: 12, depth_in: 3).call
    assert_equal 1, result[:truckloads]
  end

  test "error when length is zero" do
    result = Construction::AsphaltCalculator.new(length_ft: 0, width_ft: 12, depth_in: 3).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when depth is zero" do
    result = Construction::AsphaltCalculator.new(length_ft: 50, width_ft: 12, depth_in: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Depth must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::AsphaltCalculator.new(length_ft: 50, width_ft: 12, depth_in: 3)
    assert_equal [], calc.errors
  end
end
