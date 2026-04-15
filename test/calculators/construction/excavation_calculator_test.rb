require "test_helper"

class Construction::ExcavationCalculatorTest < ActiveSupport::TestCase
  test "rectangular pit basic calculation" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    # 20 * 15 * 8 = 2400 cu ft
    assert_in_delta 2400.0, result[:bank_cubic_feet], 0.01
    # 2400 / 27 = 88.89 cu yd
    assert_in_delta 88.89, result[:bank_cubic_yards], 0.01
  end

  test "loose volume applies swell factor" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8, swell_pct: 25).call
    # 88.89 * 1.25 ≈ 111.11
    assert_in_delta 111.11, result[:loose_cubic_yards], 0.01
  end

  test "circular pit uses diameter as length" do
    result = Construction::ExcavationCalculator.new(length_ft: 10, width_ft: 0, depth_ft: 5, shape: "circular").call
    assert_equal true, result[:valid]
    # π * 5² * 5 ≈ 392.7 cu ft
    assert_in_delta 392.7, result[:bank_cubic_feet], 0.5
  end

  test "truckloads rounds up" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8).call
    # loose ≈ 111.11 cu yd, 10-cy trucks → 12 loads
    assert_equal 12, result[:truckloads]
  end

  test "error when depth is zero" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 0).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Depth must be greater than zero"
  end

  test "error for invalid shape" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8, shape: "triangle").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Shape must be rectangular or circular"
  end

  test "error for negative swell" do
    result = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8, swell_pct: -5).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Swell percent cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::ExcavationCalculator.new(length_ft: 20, width_ft: 15, depth_ft: 8)
    assert_equal [], calc.errors
  end
end
