require "test_helper"

class Everyday::ColorPalettePickerCalculatorTest < ActiveSupport::TestCase
  test "converts 6-digit hex" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "#3B82F6").call
    assert_equal true, result[:valid]
    assert_equal "#3B82F6", result[:hex]
    assert_equal({ r: 59, g: 130, b: 246 }, result[:rgb])
    assert_equal "rgb(59, 130, 246)", result[:rgb_string]
  end

  test "converts 3-digit hex" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "#FFF").call
    assert_equal true, result[:valid]
    assert_equal({ r: 255, g: 255, b: 255 }, result[:rgb])
  end

  test "handles hex without hash" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "000000").call
    assert_equal true, result[:valid]
    assert_equal({ r: 0, g: 0, b: 0 }, result[:rgb])
  end

  test "error when empty" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Hex color cannot be empty"
  end

  test "error when invalid" do
    result = Everyday::ColorPalettePickerCalculator.new(hex: "ZZZZZZ").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Invalid hex color"
  end
end
