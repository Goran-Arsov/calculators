require "test_helper"

class Everyday::Base64EncoderCalculatorTest < ActiveSupport::TestCase
  test "encodes text to standard Base64" do
    result = Everyday::Base64EncoderCalculator.new(text: "Hello World", action: "encode").call
    assert result[:valid]
    assert_equal "SGVsbG8gV29ybGQ=", result[:standard]
  end

  test "encodes text to URL-safe Base64" do
    result = Everyday::Base64EncoderCalculator.new(text: "Hello World", action: "encode").call
    assert result[:valid]
    assert_equal "SGVsbG8gV29ybGQ=", result[:url_safe]
  end

  test "decodes standard Base64" do
    result = Everyday::Base64EncoderCalculator.new(text: "SGVsbG8gV29ybGQ=", action: "decode").call
    assert result[:valid]
    assert_equal "Hello World", result[:decoded]
  end

  test "encodes special characters" do
    result = Everyday::Base64EncoderCalculator.new(text: "user@example.com", action: "encode").call
    assert result[:valid]
    assert_equal "dXNlckBleGFtcGxlLmNvbQ==", result[:standard]
  end

  test "decodes special characters" do
    result = Everyday::Base64EncoderCalculator.new(text: "dXNlckBleGFtcGxlLmNvbQ==", action: "decode").call
    assert result[:valid]
    assert_equal "user@example.com", result[:decoded]
  end

  test "returns character length stats on encode" do
    result = Everyday::Base64EncoderCalculator.new(text: "Hello", action: "encode").call
    assert result[:valid]
    assert_equal 5, result[:input_length]
    assert_equal 8, result[:output_length]
  end

  test "returns byte size stats on encode" do
    result = Everyday::Base64EncoderCalculator.new(text: "Hello", action: "encode").call
    assert result[:valid]
    assert result[:input_bytes].positive?
    assert result[:output_bytes].positive?
  end

  test "returns error for empty text" do
    result = Everyday::Base64EncoderCalculator.new(text: "", action: "encode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid action" do
    result = Everyday::Base64EncoderCalculator.new(text: "hello", action: "transform").call
    assert_not result[:valid]
    assert_includes result[:errors], "Action must be encode or decode"
  end

  test "returns error for invalid Base64 input" do
    result = Everyday::Base64EncoderCalculator.new(text: "not!!valid!!base64", action: "decode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Invalid Base64 input"
  end

  test "encodes empty-looking whitespace as invalid" do
    result = Everyday::Base64EncoderCalculator.new(text: "   ", action: "encode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "encodes unicode text" do
    result = Everyday::Base64EncoderCalculator.new(text: "cafe\u0301", action: "encode").call
    assert result[:valid]
    assert result[:standard].length.positive?
  end

  test "round-trips encode then decode" do
    original = "The quick brown fox jumps over the lazy dog"
    encoded = Everyday::Base64EncoderCalculator.new(text: original, action: "encode").call
    decoded = Everyday::Base64EncoderCalculator.new(text: encoded[:standard], action: "decode").call
    assert_equal original, decoded[:decoded]
  end
end
