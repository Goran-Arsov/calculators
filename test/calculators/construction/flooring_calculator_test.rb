require "test_helper"

class Construction::FlooringCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "12x10 → area=120 sqft" do
    result = Construction::FlooringCalculator.new(length: 12, width: 10).call
    assert_nil result[:errors]
    assert_equal 120.0, result[:area_sqft]
  end

  test "area with waste is larger than base area" do
    result = Construction::FlooringCalculator.new(length: 12, width: 10, waste_pct: 10).call
    assert_nil result[:errors]
    assert_equal 120.0, result[:area_sqft]
    assert_equal 132.0, result[:area_with_waste]
  end

  test "boxes needed rounds up" do
    result = Construction::FlooringCalculator.new(length: 10, width: 10, waste_pct: 0).call
    assert_nil result[:errors]
    # 100 sqft / 20 sqft per box = 5 boxes
    assert_equal 5, result[:boxes_needed]
  end

  test "zero waste percentage" do
    result = Construction::FlooringCalculator.new(length: 15, width: 10, waste_pct: 0).call
    assert_nil result[:errors]
    assert_equal 150.0, result[:area_sqft]
    assert_equal 150.0, result[:area_with_waste]
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::FlooringCalculator.new(length: 0, width: 10).call
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when waste percentage is negative" do
    result = Construction::FlooringCalculator.new(length: 12, width: 10, waste_pct: -5).call
    assert result[:errors].any?
    assert_includes result[:errors], "Waste percentage cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::FlooringCalculator.new(length: 12, width: 10)
    assert_equal [], calc.errors
  end
end
