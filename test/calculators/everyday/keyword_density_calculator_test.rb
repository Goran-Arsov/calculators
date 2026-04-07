require "test_helper"

class Everyday::KeywordDensityCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "analyzes basic text correctly" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "ruby rails ruby rails ruby testing"
    ).call
    assert result[:valid]
    assert_equal 6, result[:total_words]
    assert_equal 3, result[:unique_words]
    assert result[:top_words].is_a?(Array)
    assert result[:top_bigrams].is_a?(Array)
    assert result[:top_trigrams].is_a?(Array)
  end

  test "returns correct word frequency sorted by count" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "apple banana apple cherry apple banana"
    ).call
    assert result[:valid]
    top = result[:top_words]
    assert_equal "apple", top.first[:word]
    assert_equal 3, top.first[:count]
    assert_equal 50.0, top.first[:density_percent]
  end

  test "filters out stop words" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "the quick brown fox jumps over the lazy dog"
    ).call
    assert result[:valid]
    words = result[:top_words].map { |w| w[:word] }
    assert_not_includes words, "the"
    assert_not_includes words, "over"
    assert_includes words, "quick"
    assert_includes words, "fox"
  end

  test "returns top 20 words max" do
    # Generate text with 25 unique non-stop words
    words = (1..25).map { |i| "word#{i}" }
    text = words.join(" ")
    result = Everyday::KeywordDensityCalculator.new(text: text).call
    assert result[:valid]
    assert result[:top_words].size <= 20
  end

  test "computes bigrams correctly" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "ruby rails ruby rails ruby rails testing"
    ).call
    assert result[:valid]
    assert result[:top_bigrams].any? { |b| b[:word] == "ruby rails" }
  end

  test "computes trigrams correctly" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "learn ruby programming learn ruby programming learn ruby programming"
    ).call
    assert result[:valid]
    assert result[:top_trigrams].any? { |t| t[:word] == "learn ruby programming" }
    trigram = result[:top_trigrams].find { |t| t[:word] == "learn ruby programming" }
    assert_equal 3, trigram[:count]
  end

  test "returns top 10 bigrams max" do
    result = Everyday::KeywordDensityCalculator.new(
      text: (1..30).map { |i| "word#{i}" }.join(" ")
    ).call
    assert result[:valid]
    assert result[:top_bigrams].size <= 10
  end

  test "returns top 10 trigrams max" do
    result = Everyday::KeywordDensityCalculator.new(
      text: (1..30).map { |i| "word#{i}" }.join(" ")
    ).call
    assert result[:valid]
    assert result[:top_trigrams].size <= 10
  end

  test "density percentage is calculated against total words" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "hello world hello world hello world hello world hello world"
    ).call
    assert result[:valid]
    hello = result[:top_words].find { |w| w[:word] == "hello" }
    assert_equal 5, hello[:count]
    assert_equal 50.0, hello[:density_percent]
  end

  test "handles text with punctuation" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "Hello, world! Hello, world. Hello world?"
    ).call
    assert result[:valid]
    hello = result[:top_words].find { |w| w[:word] == "hello" }
    assert_equal 3, hello[:count]
  end

  test "unique words count is correct" do
    result = Everyday::KeywordDensityCalculator.new(
      text: "apple banana cherry apple banana"
    ).call
    assert result[:valid]
    assert_equal 3, result[:unique_words]
  end

  # --- Edge cases ---

  test "error when text is empty" do
    result = Everyday::KeywordDensityCalculator.new(text: "").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "error when text is only whitespace" do
    result = Everyday::KeywordDensityCalculator.new(text: "   ").call
    assert_equal false, result[:valid]
  end

  test "handles text with only stop words" do
    result = Everyday::KeywordDensityCalculator.new(text: "the is are was and or but").call
    assert result[:valid]
    assert_equal 7, result[:total_words]
    assert result[:top_words].empty?
  end

  test "string coercion works for text" do
    result = Everyday::KeywordDensityCalculator.new(text: 12345).call
    assert result[:valid]
    assert_equal 1, result[:total_words]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::KeywordDensityCalculator.new(text: "test")
    assert_equal [], calc.errors
  end
end
