require "test_helper"

class Everyday::WordCounterCalculatorTest < ActiveSupport::TestCase
  test "counts words in a simple sentence" do
    result = Everyday::WordCounterCalculator.new(text: "Hello world foo bar").call
    assert result[:valid]
    assert_equal 4, result[:word_count]
  end

  test "counts characters with and without spaces" do
    result = Everyday::WordCounterCalculator.new(text: "Hello world").call
    assert result[:valid]
    assert_equal 11, result[:character_count]
    assert_equal 10, result[:character_count_no_spaces]
  end

  test "counts sentences by terminal punctuation" do
    result = Everyday::WordCounterCalculator.new(text: "Hello world. How are you? I am fine!").call
    assert result[:valid]
    assert_equal 3, result[:sentence_count]
  end

  test "counts paragraphs separated by blank lines" do
    text = "First paragraph.\n\nSecond paragraph.\n\nThird paragraph."
    result = Everyday::WordCounterCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 3, result[:paragraph_count]
  end

  test "single block of text counts as one paragraph" do
    result = Everyday::WordCounterCalculator.new(text: "Just one paragraph here.").call
    assert result[:valid]
    assert_equal 1, result[:paragraph_count]
  end

  test "calculates reading time based on 238 WPM" do
    words = ([ "word" ] * 476).join(" ")
    result = Everyday::WordCounterCalculator.new(text: words).call
    assert result[:valid]
    assert_equal 2, result[:reading_time_minutes]
  end

  test "calculates speaking time based on 150 WPM" do
    words = ([ "word" ] * 300).join(" ")
    result = Everyday::WordCounterCalculator.new(text: words).call
    assert result[:valid]
    assert_equal 2, result[:speaking_time_minutes]
  end

  test "returns error for empty text" do
    result = Everyday::WordCounterCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for whitespace-only text" do
    result = Everyday::WordCounterCalculator.new(text: "   \n\t  ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles unicode text" do
    result = Everyday::WordCounterCalculator.new(text: "Cafe resume naif").call
    assert result[:valid]
    assert_equal 3, result[:word_count]
  end

  test "handles text with multiple spaces between words" do
    result = Everyday::WordCounterCalculator.new(text: "Hello    world   foo").call
    assert result[:valid]
    assert_equal 3, result[:word_count]
  end

  test "reading time rounds up to at least 1 minute" do
    result = Everyday::WordCounterCalculator.new(text: "Hello").call
    assert result[:valid]
    assert_equal 1, result[:reading_time_minutes]
  end
end
