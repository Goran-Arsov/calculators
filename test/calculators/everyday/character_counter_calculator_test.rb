require "test_helper"

class Everyday::CharacterCounterCalculatorTest < ActiveSupport::TestCase
  test "counts total characters including spaces" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello world").call
    assert result[:valid]
    assert_equal 11, result[:character_count]
  end

  test "counts characters without spaces" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello world").call
    assert result[:valid]
    assert_equal 10, result[:character_count_no_spaces]
  end

  test "counts letters only" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello 123!").call
    assert result[:valid]
    assert_equal 5, result[:letter_count]
  end

  test "counts digits only" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello 123!").call
    assert result[:valid]
    assert_equal 3, result[:digit_count]
  end

  test "counts special characters" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello! @world#").call
    assert result[:valid]
    assert_equal 3, result[:special_character_count]
  end

  test "counts lines" do
    result = Everyday::CharacterCounterCalculator.new(text: "Line 1\nLine 2\nLine 3").call
    assert result[:valid]
    assert_equal 3, result[:line_count]
  end

  test "counts words" do
    result = Everyday::CharacterCounterCalculator.new(text: "One two three four").call
    assert result[:valid]
    assert_equal 4, result[:word_count]
  end

  test "returns error for empty text" do
    result = Everyday::CharacterCounterCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles unicode characters" do
    result = Everyday::CharacterCounterCalculator.new(text: "cafe").call
    assert result[:valid]
    assert_equal 4, result[:letter_count]
  end

  test "single line counts as one line" do
    result = Everyday::CharacterCounterCalculator.new(text: "Hello world").call
    assert result[:valid]
    assert_equal 1, result[:line_count]
  end

  test "handles text with only special characters" do
    result = Everyday::CharacterCounterCalculator.new(text: "!@#$%").call
    assert result[:valid]
    assert_equal 0, result[:letter_count]
    assert_equal 0, result[:digit_count]
    assert_equal 5, result[:special_character_count]
  end
end
