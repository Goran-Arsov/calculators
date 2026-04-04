require "test_helper"

class Construction::GravelMulchCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "10x10x3 inches → tons > 0" do
    result = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3).call
    assert_nil result[:errors]
    assert result[:tons] > 0
    assert result[:cubic_yards] > 0
  end

  test "area calculated correctly" do
    result = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3).call
    assert_nil result[:errors]
    assert_equal 100.0, result[:area_sqft]
  end

  test "cubic yards and tons scale with volume" do
    small = Construction::GravelMulchCalculator.new(length_ft: 5, width_ft: 5, depth_in: 3).call
    large = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3).call
    assert large[:cubic_yards] > small[:cubic_yards]
    assert large[:tons] > small[:tons]
  end

  # --- Validation errors ---

  test "error when width is zero" do
    result = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 0, depth_in: 3).call
    assert result[:errors].any?
    assert_includes result[:errors], "Width must be greater than zero"
  end

  test "error when depth is zero" do
    result = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 0).call
    assert result[:errors].any?
    assert_includes result[:errors], "Depth must be greater than zero"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::GravelMulchCalculator.new(length_ft: 10, width_ft: 10, depth_in: 3)
    assert_equal [], calc.errors
  end
end
