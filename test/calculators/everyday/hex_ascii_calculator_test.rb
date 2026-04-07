require "test_helper"

class Everyday::HexAsciiCalculatorTest < ActiveSupport::TestCase
  test "converts text to hex spaced" do
    result = Everyday::HexAsciiCalculator.new(text: "Hello", action: "text_to_hex").call
    assert result[:valid]
    assert_equal "48 65 6C 6C 6F", result[:hex_spaced]
  end

  test "converts text to hex compact" do
    result = Everyday::HexAsciiCalculator.new(text: "Hello", action: "text_to_hex").call
    assert result[:valid]
    assert_equal "48656c6c6f", result[:hex_compact]
  end

  test "converts text to hex prefixed" do
    result = Everyday::HexAsciiCalculator.new(text: "Hi", action: "text_to_hex").call
    assert result[:valid]
    assert_equal "0x48 0x69", result[:hex_prefixed]
  end

  test "converts text to binary" do
    result = Everyday::HexAsciiCalculator.new(text: "A", action: "text_to_hex").call
    assert result[:valid]
    assert_equal "01000001", result[:binary]
  end

  test "converts text to decimal" do
    result = Everyday::HexAsciiCalculator.new(text: "A", action: "text_to_hex").call
    assert result[:valid]
    assert_equal "65", result[:decimal]
  end

  test "converts hex to text" do
    result = Everyday::HexAsciiCalculator.new(text: "48 65 6C 6C 6F", action: "hex_to_text").call
    assert result[:valid]
    assert_equal "Hello", result[:decoded]
  end

  test "converts compact hex to text" do
    result = Everyday::HexAsciiCalculator.new(text: "48656c6c6f", action: "hex_to_text").call
    assert result[:valid]
    assert_equal "Hello", result[:decoded]
  end

  test "converts prefixed hex to text" do
    result = Everyday::HexAsciiCalculator.new(text: "0x48 0x69", action: "hex_to_text").call
    assert result[:valid]
    assert_equal "Hi", result[:decoded]
  end

  test "returns char and byte counts" do
    result = Everyday::HexAsciiCalculator.new(text: "Hello", action: "text_to_hex").call
    assert result[:valid]
    assert_equal 5, result[:char_count]
    assert_equal 5, result[:byte_count]
  end

  test "returns error for empty text" do
    result = Everyday::HexAsciiCalculator.new(text: "", action: "text_to_hex").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid action" do
    result = Everyday::HexAsciiCalculator.new(text: "hello", action: "convert").call
    assert_not result[:valid]
    assert_includes result[:errors], "Action must be text_to_hex or hex_to_text"
  end
end
