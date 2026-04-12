require "test_helper"

class Everyday::ColorContrastCheckerCalculatorTest < ActiveSupport::TestCase
  test "black on white gives 21:1 ratio" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#000000", background: "#FFFFFF").call
    assert_equal true, result[:valid]
    assert_equal 21.0, result[:contrast_ratio]
    assert_equal true, result[:aa_normal]
    assert_equal true, result[:aa_large]
    assert_equal true, result[:aaa_normal]
    assert_equal true, result[:aaa_large]
  end

  test "white on white gives 1:1 ratio" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#FFFFFF", background: "#FFFFFF").call
    assert_equal true, result[:valid]
    assert_equal 1.0, result[:contrast_ratio]
    assert_equal false, result[:aa_normal]
    assert_equal false, result[:aa_large]
  end

  test "handles 3-character hex codes" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#000", background: "#FFF").call
    assert_equal true, result[:valid]
    assert_equal 21.0, result[:contrast_ratio]
  end

  test "handles hex without hash" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "000000", background: "FFFFFF").call
    assert_equal true, result[:valid]
    assert_equal 21.0, result[:contrast_ratio]
  end

  test "AA normal requires 4.5:1" do
    # Gray on white has ratio around 4.6:1
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#767676", background: "#FFFFFF").call
    assert_equal true, result[:valid]
    assert result[:contrast_ratio] >= 4.5
    assert_equal true, result[:aa_normal]
  end

  test "normalizes hex output" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#abc", background: "#fff").call
    assert_equal true, result[:valid]
    assert_equal "#AABBCC", result[:foreground]
    assert_equal "#FFFFFF", result[:background]
  end

  test "error when foreground is empty" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "", background: "#FFFFFF").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Foreground color is required"
  end

  test "error when background is empty" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#000000", background: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Background color is required"
  end

  test "error for invalid hex" do
    result = Everyday::ColorContrastCheckerCalculator.new(foreground: "#GGGGGG", background: "#FFFFFF").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("valid hex") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ColorContrastCheckerCalculator.new(foreground: "#000", background: "#FFF")
    assert_equal [], calc.errors
  end
end
