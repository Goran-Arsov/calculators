require "test_helper"

class Everyday::StringEncoderCalculatorTest < ActiveSupport::TestCase
  test "base64 encodes text" do
    result = Everyday::StringEncoderCalculator.new(text: "Hello World", operation: "encode").call
    assert result[:valid]
    assert_equal "SGVsbG8gV29ybGQ=", result[:base64]
  end

  test "base64 decodes text" do
    result = Everyday::StringEncoderCalculator.new(text: "SGVsbG8gV29ybGQ=", operation: "decode").call
    assert result[:valid]
    assert_equal "Hello World", result[:base64]
  end

  test "URL encodes text" do
    result = Everyday::StringEncoderCalculator.new(text: "hello world&foo=bar", operation: "encode").call
    assert result[:valid]
    assert_equal "hello+world%26foo%3Dbar", result[:url_encoded]
  end

  test "URL decodes text" do
    result = Everyday::StringEncoderCalculator.new(text: "hello+world%26foo%3Dbar", operation: "decode").call
    assert result[:valid]
    assert_equal "hello world&foo=bar", result[:url_decoded]
  end

  test "HTML entity encodes text" do
    result = Everyday::StringEncoderCalculator.new(text: '<script>alert("xss")</script>', operation: "encode").call
    assert result[:valid]
    assert_equal "&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;", result[:html_entities]
  end

  test "HTML entity decodes text" do
    result = Everyday::StringEncoderCalculator.new(text: "&lt;b&gt;bold&lt;/b&gt;", operation: "decode").call
    assert result[:valid]
    assert_equal "<b>bold</b>", result[:html_entities]
  end

  test "returns error for empty text" do
    result = Everyday::StringEncoderCalculator.new(text: "", operation: "encode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid operation" do
    result = Everyday::StringEncoderCalculator.new(text: "hello", operation: "transform").call
    assert_not result[:valid]
    assert_includes result[:errors], "Operation must be encode or decode"
  end

  test "handles invalid base64 input gracefully" do
    result = Everyday::StringEncoderCalculator.new(text: "not valid base64!!!", operation: "decode").call
    assert result[:valid]
    assert_nil result[:base64]
    assert_equal "Invalid Base64 input", result[:base64_error]
  end

  test "encodes special characters in URL encoding" do
    result = Everyday::StringEncoderCalculator.new(text: "price=10&currency=$", operation: "encode").call
    assert result[:valid]
    assert_includes result[:url_encoded], "%24"
  end
end
