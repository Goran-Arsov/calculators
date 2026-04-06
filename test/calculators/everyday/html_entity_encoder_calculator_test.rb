require "test_helper"

class Everyday::HtmlEntityEncoderCalculatorTest < ActiveSupport::TestCase
  test "encodes basic HTML characters with named entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: '<p class="hello">Tom & Jerry</p>', direction: :encode).call
    assert result[:valid]
    assert_includes result[:named_entities], "&lt;"
    assert_includes result[:named_entities], "&gt;"
    assert_includes result[:named_entities], "&amp;"
    assert_includes result[:named_entities], "&quot;"
  end

  test "encodes with numeric entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "<b>Hello</b>", direction: :encode).call
    assert result[:valid]
    assert_includes result[:numeric_entities], "&#60;"
    assert_includes result[:numeric_entities], "&#62;"
  end

  test "encodes ampersand" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "a & b", direction: :encode).call
    assert result[:valid]
    assert_equal "a &amp; b", result[:named_entities]
    assert_equal "a &#38; b", result[:numeric_entities]
  end

  test "encodes single quotes" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "it's", direction: :encode).call
    assert result[:valid]
    assert_includes result[:named_entities], "&apos;"
  end

  test "encodes non-ASCII characters" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "\u00a9 2024", direction: :encode).call
    assert result[:valid]
    assert_includes result[:named_entities], "&copy;"
  end

  test "basic escaped uses CGI.escapeHTML" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "<script>alert('xss')</script>", direction: :encode).call
    assert result[:valid]
    assert_equal "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;", result[:basic_escaped]
  end

  test "returns character counts" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "a & b", direction: :encode).call
    assert result[:valid]
    assert_equal 5, result[:character_count]
    assert result[:encoded_character_count] > result[:character_count]
  end

  test "returns entity count" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "a & b < c", direction: :encode).call
    assert result[:valid]
    assert result[:entities_used] >= 2
  end

  test "decodes named HTML entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&lt;p&gt;Hello&lt;/p&gt;", direction: :decode).call
    assert result[:valid]
    assert_equal "<p>Hello</p>", result[:decoded]
  end

  test "decodes numeric entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&#60;b&#62;Bold&#60;/b&#62;", direction: :decode).call
    assert result[:valid]
    assert_equal "<b>Bold</b>", result[:decoded]
  end

  test "decodes hex entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&#x3C;p&#x3E;", direction: :decode).call
    assert result[:valid]
    assert_equal "<p>", result[:decoded]
  end

  test "decodes ampersand entity" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "Tom &amp; Jerry", direction: :decode).call
    assert result[:valid]
    assert_equal "Tom & Jerry", result[:decoded]
  end

  test "decodes mixed entities" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&lt;a href=&quot;url&quot;&gt;link&lt;/a&gt;", direction: :decode).call
    assert result[:valid]
    assert_equal '<a href="url">link</a>', result[:decoded]
  end

  test "decodes copyright symbol" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&copy; 2024", direction: :decode).call
    assert result[:valid]
    assert_equal "\u00a9 2024", result[:decoded]
  end

  test "returns entities found count on decode" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "&lt;b&gt;text&lt;/b&gt;", direction: :decode).call
    assert result[:valid]
    assert_equal 4, result[:entities_found]
  end

  test "returns error for empty text" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "", direction: :encode).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "   ", direction: :encode).call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid direction" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "hello", direction: :invalid).call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid direction. Use :encode or :decode"
  end

  test "handles plain text without special characters" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "Hello World", direction: :encode).call
    assert result[:valid]
    assert_equal "Hello World", result[:named_entities]
    assert_equal "Hello World", result[:numeric_entities]
    assert_equal 0, result[:entities_used]
  end

  test "roundtrip encode then decode" do
    original = '<div class="test">Hello & goodbye</div>'
    encoded = Everyday::HtmlEntityEncoderCalculator.new(text: original, direction: :encode).call
    decoded = Everyday::HtmlEntityEncoderCalculator.new(text: encoded[:named_entities], direction: :decode).call
    assert decoded[:valid]
    assert_equal original, decoded[:decoded]
  end

  test "handles euro sign encoding" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "Price: 10\u20ac", direction: :encode).call
    assert result[:valid]
    assert_includes result[:named_entities], "&euro;"
  end

  test "handles em dash encoding" do
    result = Everyday::HtmlEntityEncoderCalculator.new(text: "word\u2014word", direction: :encode).call
    assert result[:valid]
    assert_includes result[:named_entities], "&mdash;"
  end
end
