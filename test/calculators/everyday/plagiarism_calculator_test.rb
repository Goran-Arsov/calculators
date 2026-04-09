require "test_helper"

class Everyday::PlagiarismCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "identical texts produce 100% similarity" do
    text = "the quick brown fox jumps over the lazy dog"
    result = Everyday::PlagiarismCalculator.new(text1: text, text2: text).call
    assert_equal true, result[:valid]
    assert_equal 100.0, result[:similarity_percent]
  end

  test "completely different texts produce 0% similarity" do
    text1 = "alpha beta gamma delta epsilon"
    text2 = "one two three four five"
    result = Everyday::PlagiarismCalculator.new(text1: text1, text2: text2).call
    assert_equal true, result[:valid]
    assert_equal 0.0, result[:similarity_percent]
  end

  test "partially overlapping texts produce intermediate similarity" do
    text1 = "the quick brown fox jumps over the lazy dog"
    text2 = "the quick brown cat sleeps on the lazy mat"
    result = Everyday::PlagiarismCalculator.new(text1: text1, text2: text2).call
    assert_equal true, result[:valid]
    assert result[:similarity_percent] > 0
    assert result[:similarity_percent] < 100
  end

  test "matching phrases count matches intersection size" do
    text1 = "the quick brown fox jumps over the lazy dog"
    text2 = "the quick brown fox runs through the lazy park"
    result = Everyday::PlagiarismCalculator.new(text1: text1, text2: text2).call
    assert_equal true, result[:valid]
    assert result[:matching_phrases_count] > 0
    assert result[:matching_phrases_count] <= result[:total_phrases_text1]
    assert result[:matching_phrases_count] <= result[:total_phrases_text2]
  end

  test "case insensitive comparison" do
    text1 = "The Quick Brown Fox"
    text2 = "the quick brown fox"
    result = Everyday::PlagiarismCalculator.new(text1: text1, text2: text2).call
    assert_equal true, result[:valid]
    assert_equal 100.0, result[:similarity_percent]
  end

  test "punctuation is removed before comparison" do
    text1 = "hello, world! how are you?"
    text2 = "hello world how are you"
    result = Everyday::PlagiarismCalculator.new(text1: text1, text2: text2).call
    assert_equal true, result[:valid]
    assert_equal 100.0, result[:similarity_percent]
  end

  test "texts shorter than 3 words produce 0 phrases" do
    result = Everyday::PlagiarismCalculator.new(text1: "hi there", text2: "hi there").call
    assert_equal true, result[:valid]
    assert_equal 0, result[:total_phrases_text1]
    assert_equal 0, result[:total_phrases_text2]
    assert_equal 0.0, result[:similarity_percent]
  end

  test "total phrases counts are returned" do
    text = "one two three four five six"
    result = Everyday::PlagiarismCalculator.new(text1: text, text2: text).call
    assert_equal true, result[:valid]
    assert result[:total_phrases_text1] > 0
    assert result[:total_phrases_text2] > 0
  end

  # --- Validation errors ---

  test "error when text1 is empty" do
    result = Everyday::PlagiarismCalculator.new(text1: "", text2: "some text here now").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Text 1 cannot be empty"
  end

  test "error when text2 is empty" do
    result = Everyday::PlagiarismCalculator.new(text1: "some text here now", text2: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Text 2 cannot be empty"
  end

  test "error when both texts are empty" do
    result = Everyday::PlagiarismCalculator.new(text1: "", text2: "").call
    assert_equal false, result[:valid]
    assert result[:errors].size >= 2
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PlagiarismCalculator.new(text1: "hello", text2: "world")
    assert_equal [], calc.errors
  end
end
