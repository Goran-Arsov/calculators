require "test_helper"

class Everyday::UrlEncoderCalculatorTest < ActiveSupport::TestCase
  test "encodes spaces as plus signs in component encoding" do
    result = Everyday::UrlEncoderCalculator.new(text: "hello world", action: "encode").call
    assert result[:valid]
    assert_equal "hello+world", result[:component_encoded]
  end

  test "encodes special characters in component encoding" do
    result = Everyday::UrlEncoderCalculator.new(text: "price=10&tax=5", action: "encode").call
    assert result[:valid]
    assert_equal "price%3D10%26tax%3D5", result[:component_encoded]
  end

  test "preserves URL structure in full encoding" do
    result = Everyday::UrlEncoderCalculator.new(text: "https://example.com/path?q=hello world", action: "encode").call
    assert result[:valid]
    assert_includes result[:full_encoded], "https://example.com/path"
  end

  test "decodes percent-encoded text" do
    result = Everyday::UrlEncoderCalculator.new(text: "hello+world%26foo%3Dbar", action: "decode").call
    assert result[:valid]
    assert_equal "hello world&foo=bar", result[:decoded]
  end

  test "decodes percent-encoded special characters" do
    result = Everyday::UrlEncoderCalculator.new(text: "user%40example.com", action: "decode").call
    assert result[:valid]
    assert_equal "user@example.com", result[:decoded]
  end

  test "encodes email address" do
    result = Everyday::UrlEncoderCalculator.new(text: "user@example.com", action: "encode").call
    assert result[:valid]
    assert_includes result[:component_encoded], "%40"
  end

  test "returns length stats" do
    result = Everyday::UrlEncoderCalculator.new(text: "hello world", action: "encode").call
    assert result[:valid]
    assert_equal 11, result[:input_length]
    assert result[:output_length].positive?
  end

  test "returns byte size stats" do
    result = Everyday::UrlEncoderCalculator.new(text: "hello", action: "encode").call
    assert result[:valid]
    assert result[:input_bytes].positive?
    assert result[:output_bytes].positive?
  end

  test "returns error for empty text" do
    result = Everyday::UrlEncoderCalculator.new(text: "", action: "encode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid action" do
    result = Everyday::UrlEncoderCalculator.new(text: "hello", action: "transform").call
    assert_not result[:valid]
    assert_includes result[:errors], "Action must be encode or decode"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::UrlEncoderCalculator.new(text: "   ", action: "encode").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "round-trips encode then decode" do
    original = "Hello World! price=10&tax=5"
    encoded = Everyday::UrlEncoderCalculator.new(text: original, action: "encode").call
    decoded = Everyday::UrlEncoderCalculator.new(text: encoded[:component_encoded], action: "decode").call
    assert_equal original, decoded[:decoded]
  end

  test "encodes unicode characters" do
    result = Everyday::UrlEncoderCalculator.new(text: "caf\u00E9", action: "encode").call
    assert result[:valid]
    assert_includes result[:component_encoded], "%"
  end
end
