require "test_helper"

class Everyday::CssFormatterCalculatorTest < ActiveSupport::TestCase
  # --- Beautify ---

  test "beautifies CSS with proper indentation" do
    code = "body{color:red;margin:0}"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  color:"
  end

  test "beautifies nested media queries" do
    code = "@media(max-width:768px){body{color:red}}"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  body"
  end

  # --- Minify ---

  test "minifies CSS by removing whitespace and comments" do
    code = "body {\n  /* main color */\n  color: red;\n  margin: 0;\n}"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "/* main color */"
    assert_not_includes result[:output], "\n"
  end

  test "removes trailing semicolons before closing brace" do
    code = "body { color: red; }"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], ";}"
  end

  # --- Stats ---

  test "calculates size savings for minification" do
    code = "body {\n  color: red;\n  margin: 0;\n}"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert result[:original_size] > result[:processed_size]
    assert result[:savings_percentage] > 0
  end

  test "counts CSS rules" do
    code = "body { color: red; } p { margin: 0; } .header { display: flex; }"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_equal 3, result[:rule_count]
  end

  test "counts selectors" do
    code = "body { color: red; } p { margin: 0; }"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_equal 2, result[:selector_count]
  end

  # --- Validation ---

  test "returns error for empty code" do
    result = Everyday::CssFormatterCalculator.new(code: "", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns error for unsupported action" do
    result = Everyday::CssFormatterCalculator.new(code: "body{}", action: :compress).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported action") }
  end

  test "returns error for whitespace-only code" do
    result = Everyday::CssFormatterCalculator.new(code: "   ", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns size information" do
    code = "body{color:red}"
    result = Everyday::CssFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_equal code.bytesize, result[:original_size]
    assert result.key?(:savings_percentage)
  end
end
