require "test_helper"

class Everyday::JsFormatterCalculatorTest < ActiveSupport::TestCase
  # --- Beautify ---

  test "beautifies JavaScript with indentation" do
    code = "function hello(){return 'world';}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  return"
  end

  test "beautifies nested blocks" do
    code = "if(true){if(false){return;}}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "    return"
  end

  # --- Minify ---

  test "minifies JavaScript by removing comments and whitespace" do
    code = "function hello() {\n  // greeting\n  return 'world';\n}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "// greeting"
  end

  test "removes multi-line comments" do
    code = "/* comment */\nvar x = 1;"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "comment"
  end

  test "preserves strings containing comment-like patterns" do
    code = 'var url = "http://example.com";'
    result = Everyday::JsFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_includes result[:output], "http"
  end

  # --- Stats ---

  test "calculates size savings for minification" do
    code = "function hello() {\n  // greeting\n  return 'world';\n}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert result[:original_size] > result[:processed_size]
    assert result[:savings_percentage] > 0
  end

  test "counts function declarations" do
    code = "function foo() {} function bar() {}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert result[:function_count] >= 2
  end

  test "counts arrow functions" do
    code = "const foo = () => {}; const bar = (x) => x;"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert result[:function_count] >= 2
  end

  test "returns line count" do
    code = "function hello(){return 'world';}"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :beautify).call
    assert result[:valid]
    assert result[:line_count] > 1
  end

  # --- Validation ---

  test "returns error for empty code" do
    result = Everyday::JsFormatterCalculator.new(code: "", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns error for unsupported action" do
    result = Everyday::JsFormatterCalculator.new(code: "var x = 1;", action: :compress).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported action") }
  end

  test "returns error for whitespace-only code" do
    result = Everyday::JsFormatterCalculator.new(code: "   ", action: :beautify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns size information" do
    code = "var x = 1;"
    result = Everyday::JsFormatterCalculator.new(code: code, action: :minify).call
    assert result[:valid]
    assert_equal code.bytesize, result[:original_size]
    assert result.key?(:savings_percentage)
  end
end
