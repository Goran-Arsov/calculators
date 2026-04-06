require "test_helper"

class Everyday::CodeMinifierCalculatorTest < ActiveSupport::TestCase
  # --- JSON ---

  test "minifies JSON by removing whitespace" do
    code = "{\n  \"name\": \"John\",\n  \"age\": 30\n}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :json, action: :minify).call
    assert result[:valid]
    assert_equal '{"name":"John","age":30}', result[:output]
  end

  test "beautifies JSON with indentation" do
    code = '{"name":"John","age":30}'
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :json, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  \"name\": \"John\""
  end

  test "returns error for invalid JSON" do
    result = Everyday::CodeMinifierCalculator.new(code: "{invalid}", language: :json, action: :minify).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "calculates size savings for JSON minification" do
    code = "{\n  \"name\": \"John\",\n  \"age\": 30\n}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :json, action: :minify).call
    assert result[:valid]
    assert result[:original_size] > result[:processed_size]
    assert result[:savings_percentage] > 0
  end

  # --- CSS ---

  test "minifies CSS by removing whitespace and comments" do
    code = "body {\n  /* main color */\n  color: red;\n  margin: 0;\n}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :css, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "/* main color */"
    assert_not_includes result[:output], "\n"
  end

  test "beautifies CSS with proper indentation" do
    code = "body{color:red;margin:0}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :css, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  color:"
  end

  test "removes trailing semicolons before closing brace in CSS" do
    code = "body { color: red; }"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :css, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], ";}"
  end

  # --- HTML ---

  test "minifies HTML by removing comments and whitespace" do
    code = "<div>\n  <!-- comment -->\n  <p>Hello</p>\n</div>"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :html, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "<!-- comment -->"
    assert_includes result[:output], "<div><p>Hello</p></div>"
  end

  test "beautifies HTML with indentation" do
    code = "<div><p>Hello</p></div>"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :html, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  <p>"
  end

  test "handles void elements in HTML beautification" do
    code = "<div><img src='test.png'><p>Text</p></div>"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :html, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "<img"
  end

  # --- JavaScript ---

  test "minifies JavaScript by removing comments and whitespace" do
    code = "function hello() {\n  // greeting\n  return 'world';\n}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :javascript, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "// greeting"
  end

  test "beautifies JavaScript with indentation" do
    code = "function hello(){return 'world';}"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :javascript, action: :beautify).call
    assert result[:valid]
    assert_includes result[:output], "  return"
  end

  test "removes multi-line JavaScript comments" do
    code = "/* comment */\nvar x = 1;"
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :javascript, action: :minify).call
    assert result[:valid]
    assert_not_includes result[:output], "comment"
  end

  # --- Validation ---

  test "returns error for empty code" do
    result = Everyday::CodeMinifierCalculator.new(code: "", language: :json, action: :minify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end

  test "returns error for unsupported language" do
    result = Everyday::CodeMinifierCalculator.new(code: "test", language: :python, action: :minify).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported language") }
  end

  test "returns error for unsupported action" do
    result = Everyday::CodeMinifierCalculator.new(code: "test", language: :json, action: :compress).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported action") }
  end

  test "returns size information" do
    code = '{"a": 1}'
    result = Everyday::CodeMinifierCalculator.new(code: code, language: :json, action: :minify).call
    assert result[:valid]
    assert_equal code.bytesize, result[:original_size]
    assert_equal result[:output].bytesize, result[:processed_size]
    assert result.key?(:savings_percentage)
  end

  test "handles whitespace-only code as empty" do
    result = Everyday::CodeMinifierCalculator.new(code: "   ", language: :json, action: :minify).call
    assert_not result[:valid]
    assert_includes result[:errors], "Code cannot be empty"
  end
end
