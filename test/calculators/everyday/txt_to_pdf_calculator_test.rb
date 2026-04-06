require "test_helper"

class Everyday::TxtToPdfCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "returns line count, word count, and char count for simple text" do
    result = Everyday::TxtToPdfCalculator.new(text: "Hello world\nThis is a test").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:line_count]
    assert_equal 6, result[:word_count]
    assert_equal 26, result[:char_count]
  end

  test "single line text" do
    result = Everyday::TxtToPdfCalculator.new(text: "One line of text").call
    assert_equal true, result[:valid]
    assert_equal 1, result[:line_count]
    assert_equal 4, result[:word_count]
    assert_equal 16, result[:char_count]
  end

  test "multi-paragraph text" do
    text = "First paragraph.\n\nSecond paragraph.\n\nThird paragraph."
    result = Everyday::TxtToPdfCalculator.new(text: text).call
    assert_equal true, result[:valid]
    assert_equal 5, result[:line_count]
    assert_equal 6, result[:word_count]
    assert_equal text.length, result[:char_count]
  end

  test "text with only newlines counts lines correctly" do
    result = Everyday::TxtToPdfCalculator.new(text: "a\nb\nc\nd").call
    assert_equal true, result[:valid]
    assert_equal 4, result[:line_count]
    assert_equal 4, result[:word_count]
  end

  test "string coercion of text parameter" do
    result = Everyday::TxtToPdfCalculator.new(text: 12345).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:line_count]
    assert_equal 1, result[:word_count]
    assert_equal 5, result[:char_count]
  end

  # --- Validation errors ---

  test "error when text is empty" do
    result = Everyday::TxtToPdfCalculator.new(text: "").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "error when text is whitespace only" do
    result = Everyday::TxtToPdfCalculator.new(text: "   \n  \t  ").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::TxtToPdfCalculator.new(text: "hello")
    assert_equal [], calc.errors
  end
end
