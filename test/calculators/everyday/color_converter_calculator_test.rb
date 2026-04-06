require "test_helper"

class Everyday::ColorConverterCalculatorTest < ActiveSupport::TestCase
  test "converts hex color to all formats" do
    result = Everyday::ColorConverterCalculator.new(color: "#FF0000").call
    assert result[:valid]
    assert_equal "#ff0000", result[:hex]
    assert_equal({ r: 255, g: 0, b: 0 }, result[:rgb])
    assert_equal "rgb(255, 0, 0)", result[:rgb_string]
    assert_equal({ h: 0, s: 100, l: 50 }, result[:hsl])
    assert_equal "hsl(0, 100%, 50%)", result[:hsl_string]
    assert_equal "Red", result[:color_name]
  end

  test "converts short hex color" do
    result = Everyday::ColorConverterCalculator.new(color: "#F00").call
    assert result[:valid]
    assert_equal "#ff0000", result[:hex]
    assert_equal({ r: 255, g: 0, b: 0 }, result[:rgb])
  end

  test "converts hex without hash" do
    result = Everyday::ColorConverterCalculator.new(color: "00FF00").call
    assert result[:valid]
    assert_equal "#00ff00", result[:hex]
    assert_equal "Lime", result[:color_name]
  end

  test "converts rgb format" do
    result = Everyday::ColorConverterCalculator.new(color: "rgb(0, 0, 255)").call
    assert result[:valid]
    assert_equal "#0000ff", result[:hex]
    assert_equal({ r: 0, g: 0, b: 255 }, result[:rgb])
    assert_equal "Blue", result[:color_name]
  end

  test "converts rgb without function notation" do
    result = Everyday::ColorConverterCalculator.new(color: "255, 165, 0").call
    assert result[:valid]
    assert_equal "#ffa500", result[:hex]
    assert_equal "Orange", result[:color_name]
  end

  test "converts hsl format" do
    result = Everyday::ColorConverterCalculator.new(color: "hsl(120, 100%, 50%)").call
    assert result[:valid]
    assert_equal({ r: 0, g: 255, b: 0 }, result[:rgb])
  end

  test "converts black" do
    result = Everyday::ColorConverterCalculator.new(color: "#000000").call
    assert result[:valid]
    assert_equal "#000000", result[:hex]
    assert_equal({ h: 0, s: 0, l: 0 }, result[:hsl])
    assert_equal "Black", result[:color_name]
    assert_in_delta 0.0, result[:luminance], 0.001
  end

  test "converts white" do
    result = Everyday::ColorConverterCalculator.new(color: "#FFFFFF").call
    assert result[:valid]
    assert_equal "#ffffff", result[:hex]
    assert_equal({ h: 0, s: 0, l: 100 }, result[:hsl])
    assert_equal "White", result[:color_name]
    assert_in_delta 1.0, result[:luminance], 0.001
  end

  test "calculates contrast ratio against white" do
    result = Everyday::ColorConverterCalculator.new(color: "#000000").call
    assert result[:valid]
    assert_in_delta 21.0, result[:contrast_white], 0.1
  end

  test "calculates contrast ratio against black" do
    result = Everyday::ColorConverterCalculator.new(color: "#FFFFFF").call
    assert result[:valid]
    assert_in_delta 21.0, result[:contrast_black], 0.1
  end

  test "wcag rating passes for high contrast" do
    result = Everyday::ColorConverterCalculator.new(color: "#000000").call
    assert result[:valid]
    assert result[:wcag_white][:aa_normal]
    assert result[:wcag_white][:aa_large]
    assert result[:wcag_white][:aaa_normal]
    assert result[:wcag_white][:aaa_large]
  end

  test "wcag rating fails for low contrast against white" do
    result = Everyday::ColorConverterCalculator.new(color: "#777777").call
    assert result[:valid]
    assert_not result[:wcag_white][:aa_normal]
    assert_not result[:wcag_white][:aaa_normal]
  end

  test "wcag rating fails for low contrast against black" do
    result = Everyday::ColorConverterCalculator.new(color: "#959595").call
    assert result[:valid]
    assert_not result[:wcag_white][:aa_normal]
  end

  test "best text color for dark background is white" do
    result = Everyday::ColorConverterCalculator.new(color: "#000080").call
    assert result[:valid]
    assert_equal "#FFFFFF", result[:best_text_color]
  end

  test "best text color for light background is black" do
    result = Everyday::ColorConverterCalculator.new(color: "#FFFF00").call
    assert result[:valid]
    assert_equal "#000000", result[:best_text_color]
  end

  test "returns custom for unnamed color" do
    result = Everyday::ColorConverterCalculator.new(color: "#123456").call
    assert result[:valid]
    assert_equal "Custom", result[:color_name]
  end

  test "returns error for empty color" do
    result = Everyday::ColorConverterCalculator.new(color: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Color value cannot be empty"
  end

  test "returns error for invalid hex" do
    result = Everyday::ColorConverterCalculator.new(color: "#GGGGGG").call
    assert_not result[:valid]
  end

  test "returns error for rgb values out of range" do
    result = Everyday::ColorConverterCalculator.new(color: "rgb(300, 0, 0)").call
    assert_not result[:valid]
    assert_includes result[:errors], "RGB values must be three integers between 0 and 255"
  end

  test "handles mid-gray correctly" do
    result = Everyday::ColorConverterCalculator.new(color: "#808080").call
    assert result[:valid]
    assert_equal "Gray", result[:color_name]
    assert_equal({ h: 0, s: 0, l: 50 }, result[:hsl])
  end

  test "converts cyan correctly" do
    result = Everyday::ColorConverterCalculator.new(color: "#00FFFF").call
    assert result[:valid]
    assert_equal "Cyan", result[:color_name]
    assert_equal({ h: 180, s: 100, l: 50 }, result[:hsl])
  end

  test "luminance is between 0 and 1" do
    result = Everyday::ColorConverterCalculator.new(color: "#336699").call
    assert result[:valid]
    assert result[:luminance] >= 0.0
    assert result[:luminance] <= 1.0
  end
end
