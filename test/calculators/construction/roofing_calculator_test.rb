require "test_helper"

class Construction::RoofingCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "40x30 roof, 6/12 pitch → bundles > 0" do
    result = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6, waste_pct: 10).call
    assert_nil result[:errors]
    assert result[:bundles] > 0
    assert result[:squares] > 0
    assert result[:felt_rolls] > 0
    assert result[:nail_boxes] > 0
  end

  test "footprint area calculated correctly" do
    result = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 0, waste_pct: 0).call
    assert_nil result[:errors]
    assert_equal 1200.0, result[:footprint_area]
    # Pitch 0 multiplier = 1.0, so roof area equals footprint
    assert_equal 1200.0, result[:roof_area]
  end

  test "pitch factor increases roof area" do
    flat = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 0, waste_pct: 0).call
    steep = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 12, waste_pct: 0).call
    assert steep[:roof_area] > flat[:roof_area]
    # 12/12 pitch multiplier is 1.414
    assert_in_delta 1200.0 * 1.414, steep[:roof_area], 0.5
  end

  test "waste percentage increases area" do
    no_waste = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6, waste_pct: 0).call
    with_waste = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6, waste_pct: 15).call
    assert with_waste[:area_with_waste] > no_waste[:area_with_waste]
  end

  test "bundles equal 3 times squares" do
    result = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6, waste_pct: 10).call
    assert_nil result[:errors]
    assert_equal result[:squares] * 3, result[:bundles]
  end

  test "string inputs are coerced" do
    result = Construction::RoofingCalculator.new(length: "40", width: "30", pitch: "6", waste_pct: "10").call
    assert_nil result[:errors]
    assert result[:bundles] > 0
  end

  # --- Validation errors ---

  test "error when length is zero" do
    result = Construction::RoofingCalculator.new(length: 0, width: 30, pitch: 6).call
    assert result[:errors].any?
    assert_includes result[:errors], "Length must be greater than zero"
  end

  test "error when width is negative" do
    result = Construction::RoofingCalculator.new(length: 40, width: -5, pitch: 6).call
    assert result[:errors].any?
    assert_includes result[:errors], "Width must be greater than zero"
  end

  test "error when pitch is out of range" do
    result = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 15).call
    assert result[:errors].any?
    assert_includes result[:errors], "Pitch must be between 0 and 12"
  end

  test "error when waste is negative" do
    result = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6, waste_pct: -5).call
    assert result[:errors].any?
    assert_includes result[:errors], "Waste percentage cannot be negative"
  end

  test "errors accessor returns empty array before call" do
    calc = Construction::RoofingCalculator.new(length: 40, width: 30, pitch: 6)
    assert_equal [], calc.errors
  end
end
