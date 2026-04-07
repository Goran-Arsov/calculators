require "test_helper"

class Everyday::CssFlexboxCalculatorTest < ActiveSupport::TestCase
  test "generates basic flexbox CSS" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row", justify_content: "center", align_items: "center",
      flex_wrap: "nowrap", gap: "10"
    ).call
    assert result[:valid]
    assert_includes result[:css_string], "display: flex;"
    assert_includes result[:css_string], "flex-direction: row;"
    assert_includes result[:css_string], "justify-content: center;"
    assert_includes result[:css_string], "align-items: center;"
    assert_includes result[:css_string], "flex-wrap: nowrap;"
    assert_includes result[:css_string], "gap: 10px;"
  end

  test "generates column direction" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "column", justify_content: "flex-start", align_items: "stretch",
      flex_wrap: "wrap", gap: "20"
    ).call
    assert result[:valid]
    assert_includes result[:css_string], "flex-direction: column;"
    assert_includes result[:css_string], "flex-wrap: wrap;"
  end

  test "omits gap when zero" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row", justify_content: "center", align_items: "center",
      flex_wrap: "nowrap", gap: "0"
    ).call
    assert result[:valid]
    assert_not_includes result[:css_string], "gap:"
  end

  test "supports all justify-content values" do
    %w[flex-start center flex-end space-between space-around space-evenly].each do |jc|
      result = Everyday::CssFlexboxCalculator.new(
        direction: "row", justify_content: jc, align_items: "center",
        flex_wrap: "nowrap", gap: "0"
      ).call
      assert result[:valid], "Expected valid for justify-content: #{jc}"
    end
  end

  test "supports all align-items values" do
    %w[stretch flex-start center flex-end baseline].each do |ai|
      result = Everyday::CssFlexboxCalculator.new(
        direction: "row", justify_content: "center", align_items: ai,
        flex_wrap: "nowrap", gap: "0"
      ).call
      assert result[:valid], "Expected valid for align-items: #{ai}"
    end
  end

  test "returns error for invalid direction" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "diagonal", justify_content: "center", align_items: "center",
      flex_wrap: "nowrap", gap: "0"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid flex-direction: diagonal"
  end

  test "returns error for invalid justify-content" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row", justify_content: "invalid", align_items: "center",
      flex_wrap: "nowrap", gap: "0"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid justify-content: invalid"
  end

  test "returns error for invalid align-items" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row", justify_content: "center", align_items: "invalid",
      flex_wrap: "nowrap", gap: "0"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid align-items: invalid"
  end

  test "returns error for negative gap" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row", justify_content: "center", align_items: "center",
      flex_wrap: "nowrap", gap: "-5"
    ).call
    assert_not result[:valid]
    assert_includes result[:errors], "Gap cannot be negative"
  end

  test "returns all expected properties" do
    result = Everyday::CssFlexboxCalculator.new(
      direction: "row-reverse", justify_content: "space-between", align_items: "baseline",
      flex_wrap: "wrap-reverse", gap: "16"
    ).call
    assert result[:valid]
    assert_equal "row-reverse", result[:direction]
    assert_equal "space-between", result[:justify_content]
    assert_equal "baseline", result[:align_items]
    assert_equal "wrap-reverse", result[:flex_wrap]
    assert_equal "16", result[:gap]
  end
end
