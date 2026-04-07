require "test_helper"

class Everyday::CssBoxShadowCalculatorTest < ActiveSupport::TestCase
  test "generates basic box shadow CSS" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 5, v_offset: 5, blur: 10, spread: 0, color: "#000000"
    ).call
    assert result[:valid]
    assert_equal "5px 5px 10px 0px #000000", result[:css_value]
    assert_equal "box-shadow: 5px 5px 10px 0px #000000;", result[:css_property]
  end

  test "generates inset shadow" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 0, v_offset: 0, blur: 15, spread: 5, color: "#FF0000", inset: true
    ).call
    assert result[:valid]
    assert_equal "inset 0px 0px 15px 5px #FF0000", result[:css_value]
  end

  test "handles negative offsets" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: -10, v_offset: -10, blur: 20, spread: 0, color: "#333333"
    ).call
    assert result[:valid]
    assert_equal "-10px -10px 20px 0px #333333", result[:css_value]
  end

  test "handles zero values" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 0, v_offset: 0, blur: 0, spread: 0, color: "#000000"
    ).call
    assert result[:valid]
    assert_equal "0px 0px 0px 0px #000000", result[:css_value]
  end

  test "returns error for negative blur" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 5, v_offset: 5, blur: -1, spread: 0, color: "#000000"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Blur radius cannot be negative"
  end

  test "returns error for empty color" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 5, v_offset: 5, blur: 10, spread: 0, color: ""
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Color cannot be empty"
  end

  test "returns error for invalid hex color" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 5, v_offset: 5, blur: 10, spread: 0, color: "red"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Color must be a valid hex value (e.g. #000000)"
  end

  test "accepts 3-character hex color" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 2, v_offset: 2, blur: 5, spread: 1, color: "#F00"
    ).call
    assert result[:valid]
    assert_equal "2px 2px 5px 1px #F00", result[:css_value]
  end

  test "accepts 8-character hex color with alpha" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 2, v_offset: 2, blur: 5, spread: 1, color: "#00000080"
    ).call
    assert result[:valid]
    assert_equal "2px 2px 5px 1px #00000080", result[:css_value]
  end

  test "returns all expected keys" do
    result = Everyday::CssBoxShadowCalculator.new(
      h_offset: 5, v_offset: 5, blur: 10, spread: 2, color: "#000000"
    ).call
    assert result[:valid]
    assert_equal 5, result[:h_offset]
    assert_equal 5, result[:v_offset]
    assert_equal 10, result[:blur]
    assert_equal 2, result[:spread]
    assert_equal "#000000", result[:color]
    assert_equal false, result[:inset]
  end
end
