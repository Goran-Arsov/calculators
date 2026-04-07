require "test_helper"

class Everyday::FaviconGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates favicon configuration with valid params" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "AB", bg_color: "#3B82F6", text_color: "#FFFFFF"
    ).call
    assert result[:valid]
    assert_equal "AB", result[:text]
    assert_equal "#3B82F6", result[:bg_color]
    assert_equal "#FFFFFF", result[:text_color]
    assert_equal 64, result[:font_size]
    assert_equal [16, 32, 48, 180], result[:sizes]
  end

  test "generates html link tags" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "X", bg_color: "#000000", text_color: "#FFFFFF"
    ).call
    assert result[:valid]
    assert_includes result[:html_tags], 'sizes="16x16"'
    assert_includes result[:html_tags], 'sizes="32x32"'
    assert_includes result[:html_tags], 'sizes="48x48"'
    assert_includes result[:html_tags], 'sizes="180x180"'
    assert_includes result[:html_tags], "apple-touch-icon"
  end

  test "accepts single character text" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "#000000", text_color: "#FFFFFF"
    ).call
    assert result[:valid]
    assert_equal "A", result[:text]
  end

  test "accepts custom font size" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "AB", bg_color: "#000000", text_color: "#FFFFFF", font_size: 48
    ).call
    assert result[:valid]
    assert_equal 48, result[:font_size]
  end

  test "returns error for empty text" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "", bg_color: "#000000", text_color: "#FFFFFF"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for text longer than 2 characters" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "ABC", bg_color: "#000000", text_color: "#FFFFFF"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text must be 1-2 characters"
  end

  test "returns error for invalid background color" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "red", text_color: "#FFFFFF"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Background color must be a valid hex value"
  end

  test "returns error for invalid text color" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "#000000", text_color: "white"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text color must be a valid hex value"
  end

  test "returns error for font size below 8" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "#000000", text_color: "#FFFFFF", font_size: 5
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Font size must be between 8 and 200"
  end

  test "returns error for font size above 200" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "#000000", text_color: "#FFFFFF", font_size: 300
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Font size must be between 8 and 200"
  end

  test "accepts 3 character hex colors" do
    result = Everyday::FaviconGeneratorCalculator.new(
      text: "A", bg_color: "#F00", text_color: "#FFF"
    ).call
    assert result[:valid]
  end
end
