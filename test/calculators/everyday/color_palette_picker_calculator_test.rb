require "test_helper"

class Everyday::ColorPalettePickerCalculatorTest < ActiveSupport::TestCase
  test "converts 6-digit hex to rgb" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "#3B82F6").call
    assert_equal true, result[:valid]
    assert_equal "#3B82F6", result[:hex]
    assert_equal({ r: 59, g: 130, b: 246 }, result[:rgb])
    assert_equal "rgb(59, 130, 246)", result[:rgb_string]
  end

  test "converts 3-digit hex" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "#FFF").call
    assert_equal true, result[:valid]
    assert_equal "#FFF", result[:hex]
    assert_equal({ r: 255, g: 255, b: 255 }, result[:rgb])
  end

  test "handles hex without hash prefix" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "000000").call
    assert_equal true, result[:valid]
    assert_equal "#000000", result[:hex]
    assert_equal({ r: 0, g: 0, b: 0 }, result[:rgb])
  end

  test "converts red" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "FF0000").call
    assert_equal true, result[:valid]
    assert_equal({ r: 255, g: 0, b: 0 }, result[:rgb])
  end

  test "case insensitive" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "aabbcc").call
    assert_equal true, result[:valid]
    assert_equal "#AABBCC", result[:hex]
  end

  # --- Validation ---

  test "error when hex is empty" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Hex color cannot be empty"
  end

  test "error when hex is invalid" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "GGGGGG").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid hex color"
  end

  test "error when hex is wrong length" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "12345").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid hex color"
  end

  test "errors accessor returns empty before call" do
    calc = Everyday::ColorPalettePickerCalculator.new(hex: "FFF")
    assert_equal [], calc.errors
  end
end
