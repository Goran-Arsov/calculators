require "test_helper"

class Everyday::TextToSpeechCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "calculates word count for simple text" do
    result = Everyday::TextToSpeechCalculator.new(text: "Hello world foo bar baz").call

    assert result[:valid]
    assert_equal 5, result[:word_count]
  end

  test "calculates character count" do
    result = Everyday::TextToSpeechCalculator.new(text: "Hello").call

    assert result[:valid]
    assert_equal 5, result[:char_count]
  end

  test "estimates duration based on 150 wpm average" do
    # 150 words should take 60 seconds
    text = (["word"] * 150).join(" ")
    result = Everyday::TextToSpeechCalculator.new(text: text).call

    assert result[:valid]
    assert_equal 150, result[:word_count]
    assert_equal 60.0, result[:estimated_duration_seconds]
  end

  test "estimates duration for short text" do
    # 30 words at 150 wpm = 12 seconds
    text = (["hello"] * 30).join(" ")
    result = Everyday::TextToSpeechCalculator.new(text: text).call

    assert result[:valid]
    assert_equal 30, result[:word_count]
    assert_equal 12.0, result[:estimated_duration_seconds]
  end

  # --- Whitespace handling ---

  test "handles multiple spaces between words" do
    result = Everyday::TextToSpeechCalculator.new(text: "hello    world").call

    assert result[:valid]
    assert_equal 2, result[:word_count]
  end

  test "handles tabs and newlines" do
    result = Everyday::TextToSpeechCalculator.new(text: "hello\tworld\nfoo").call

    assert result[:valid]
    assert_equal 3, result[:word_count]
  end

  test "character count includes whitespace" do
    result = Everyday::TextToSpeechCalculator.new(text: "a b").call

    assert result[:valid]
    assert_equal 3, result[:char_count]
  end

  # --- Validation ---

  test "empty text returns error" do
    result = Everyday::TextToSpeechCalculator.new(text: "").call

    refute result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "whitespace-only text returns error" do
    result = Everyday::TextToSpeechCalculator.new(text: "   ").call

    refute result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  # --- Edge cases ---

  test "single word" do
    result = Everyday::TextToSpeechCalculator.new(text: "hello").call

    assert result[:valid]
    assert_equal 1, result[:word_count]
    assert_equal 5, result[:char_count]
    assert_equal 0.4, result[:estimated_duration_seconds]
  end

  test "very long text" do
    text = (["supercalifragilistic"] * 1000).join(" ")
    result = Everyday::TextToSpeechCalculator.new(text: text).call

    assert result[:valid]
    assert_equal 1000, result[:word_count]
    assert_equal 400.0, result[:estimated_duration_seconds]
  end

  # --- String coercion ---

  test "nil text is coerced to empty string and returns error" do
    result = Everyday::TextToSpeechCalculator.new(text: nil).call

    refute result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "numeric input is coerced to string" do
    result = Everyday::TextToSpeechCalculator.new(text: 12345).call

    assert result[:valid]
    assert_equal 1, result[:word_count]
    assert_equal 5, result[:char_count]
  end
end
