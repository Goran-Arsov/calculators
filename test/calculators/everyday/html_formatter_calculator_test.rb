require "test_helper"

class Everyday::HtmlFormatterCalculatorTest < ActiveSupport::TestCase
  # --- Beautify ---

  test "beautifies HTML with proper indentation" do
    code = "<div><p>Hello</p></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  <p>"
  end

  test "beautifies nested HTML" do
    code = "<html><body><div><p>Text</p></div></body></html>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "    <p>"
  end

  test "handles void elements without extra indentation" do
    code = "<div><img src='test.png'><p>Text</p></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "<img"
  end

  test "removes HTML comments during beautification" do
    code = "<div><!-- comment --><p>Text</p></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_not_includes result[:output], "<!-- comment -->"
  end

  # --- Minify ---

  test "minifies HTML by removing whitespace" do
    code = "<div>\n  <p>Hello</p>\n</div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_includes result[:output], "<div><p>Hello</p></div>"
  end

  test "minifies HTML by removing comments" do
    code = "<div><!-- comment --><p>Hello</p></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "<!-- comment -->"
  end

  # --- Stats ---

  test "calculates size savings for minification" do
    code = "<div>\n  <p>Hello</p>\n</div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert result[:original_size] > result[:processed_size]
    assert result[:savings_percentage] > 0
  end

  test "counts tags" do
    code = "<div><p>Hello</p><span>World</span></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_equal 3, result[:tag_count]
  end

  test "detects doctype" do
    code = "<!DOCTYPE html><html><body></body></html>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert result[:has_doctype]
  end

  test "detects missing doctype" do
    code = "<html><body></body></html>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_not result[:has_doctype]
  end

  # --- Validation ---

  test "returns error for empty code" do
    result = Everyday::HtmlFormatterCalculator.new(code: "", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns error for unsupported action" do
    result = Everyday::HtmlFormatterCalculator.new(code: "<div></div>", action: :compress).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported action") }
  end

  test "returns error for whitespace-only code" do
    result = Everyday::HtmlFormatterCalculator.new(code: "   ", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns size information" do
    code = "<div><p>Hello</p></div>"
    result = Everyday::HtmlFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_equal code.bytesize, result[:original_size]
    assert result.key?(:savings_percentage)
  end
end
