require "test_helper"

class Everyday::QrCodeGeneratorCalculatorTest < ActiveSupport::TestCase
  test "detects URL type" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "https://example.com").call
    assert result[:valid]
    assert_equal "https://example.com", result[:text]
    assert_equal 19, result[:character_count]
    assert_equal "url", result[:type]
  end

  test "detects http URL type" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "http://example.com/page?q=1").call
    assert result[:valid]
    assert_equal "url", result[:type]
  end

  test "detects email type" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "user@example.com").call
    assert result[:valid]
    assert_equal "email", result[:type]
  end

  test "detects phone type" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "+1-555-123-4567").call
    assert result[:valid]
    assert_equal "phone", result[:type]
  end

  test "detects plain text type" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "Hello World").call
    assert result[:valid]
    assert_equal "text", result[:type]
  end

  test "returns character count" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "abc").call
    assert result[:valid]
    assert_equal 3, result[:character_count]
  end

  test "returns error for empty text" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "   ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for text exceeding max length" do
    long_text = "a" * 2049
    result = Everyday::QrCodeGeneratorCalculator.new(text: long_text).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("maximum length") }
  end

  test "accepts text at max length" do
    text = "a" * 2048
    result = Everyday::QrCodeGeneratorCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 2048, result[:character_count]
  end

  test "detects phone with parentheses" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "(555) 123-4567").call
    assert result[:valid]
    assert_equal "phone", result[:type]
  end

  test "url detection is case insensitive" do
    result = Everyday::QrCodeGeneratorCalculator.new(text: "HTTPS://EXAMPLE.COM").call
    assert result[:valid]
    assert_equal "url", result[:type]
  end
end
