require "test_helper"

class Everyday::EscapeUnescapeCalculatorTest < ActiveSupport::TestCase
  # --- JSON ---

  test "escapes JSON special characters" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "Hello \"world\"\nNew line", format: :json, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], '\\"'
    assert_includes result[:output], "\\n"
  end

  test "unescapes JSON escape sequences" do
    result = Everyday::EscapeUnescapeCalculator.new(text: 'Hello \\"world\\"\\nNew line', format: :json, action: :unescape).call
    assert result[:valid]
    assert_includes result[:output], '"world"'
    assert_includes result[:output], "\n"
  end

  test "escapes JSON backslashes" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "path\\to\\file", format: :json, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "\\\\"
  end

  # --- URL ---

  test "escapes URL reserved characters" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "hello world&foo=bar", format: :url, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "hello+world"
    assert_includes result[:output], "%26"
  end

  test "unescapes URL percent-encoded characters" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "hello+world%26foo%3Dbar", format: :url, action: :unescape).call
    assert result[:valid]
    assert_equal "hello world&foo=bar", result[:output]
  end

  # --- HTML ---

  test "escapes HTML special characters" do
    result = Everyday::EscapeUnescapeCalculator.new(text: '<script>alert("xss")</script>', format: :html, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "&lt;"
    assert_includes result[:output], "&gt;"
    assert_includes result[:output], "&quot;"
  end

  test "unescapes HTML entities" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "&lt;div&gt;Hello&lt;/div&gt;", format: :html, action: :unescape).call
    assert result[:valid]
    assert_equal "<div>Hello</div>", result[:output]
  end

  test "escapes ampersand in HTML" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "Tom & Jerry", format: :html, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "&amp;"
  end

  # --- Backslash ---

  test "escapes backslash sequences" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "line1\nline2\ttab", format: :backslash, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "\\n"
    assert_includes result[:output], "\\t"
  end

  test "unescapes backslash sequences" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "line1\\nline2\\ttab", format: :backslash, action: :unescape).call
    assert result[:valid]
    assert_includes result[:output], "\n"
    assert_includes result[:output], "\t"
  end

  test "escapes backslash double quotes" do
    result = Everyday::EscapeUnescapeCalculator.new(text: 'say "hello"', format: :backslash, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], '\\"'
  end

  # --- Unicode ---

  test "escapes non-ASCII characters to unicode sequences" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "cafe\u0301", format: :unicode, action: :escape).call
    assert result[:valid]
    assert_includes result[:output], "\\u"
    assert_includes result[:output], "cafe"
  end

  test "unescapes unicode sequences" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "caf\\u00E9", format: :unicode, action: :unescape).call
    assert result[:valid]
    assert_includes result[:output], "\u00E9"
  end

  test "preserves ASCII characters in unicode escape" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "hello", format: :unicode, action: :escape).call
    assert result[:valid]
    assert_equal "hello", result[:output]
  end

  # --- Validation ---

  test "returns error for empty text" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "", format: :json, action: :escape).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for unsupported format" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "test", format: :xml, action: :escape).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported format") }
  end

  test "returns error for unsupported action" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "test", format: :json, action: :encode).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported action") }
  end

  test "returns character counts" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "Hello", format: :json, action: :escape).call
    assert result[:valid]
    assert_equal 5, result[:input_length]
    assert_equal 5, result[:output_length]
  end

  test "handles whitespace-only text as empty" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "   ", format: :json, action: :escape).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns format and action in result" do
    result = Everyday::EscapeUnescapeCalculator.new(text: "test", format: :html, action: :escape).call
    assert result[:valid]
    assert_equal "html", result[:format]
    assert_equal "escape", result[:action]
  end
end
