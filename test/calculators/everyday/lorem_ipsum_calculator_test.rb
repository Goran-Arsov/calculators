require "test_helper"

class Everyday::LoremIpsumCalculatorTest < ActiveSupport::TestCase
  test "generates paragraphs" do
    result = Everyday::LoremIpsumCalculator.new(count: 3, unit: "paragraphs").call
    assert result[:valid]
    paragraphs = result[:text].split("\n\n")
    assert_equal 3, paragraphs.size
  end

  test "generates sentences" do
    result = Everyday::LoremIpsumCalculator.new(count: 5, unit: "sentences").call
    assert result[:valid]
    sentences = result[:text].scan(/[.!?]/).size
    assert_equal 5, sentences
  end

  test "generates specific word count" do
    result = Everyday::LoremIpsumCalculator.new(count: 20, unit: "words").call
    assert result[:valid]
    assert_equal 20, result[:word_count]
  end

  test "returns word count for paragraphs" do
    result = Everyday::LoremIpsumCalculator.new(count: 1, unit: "paragraphs").call
    assert result[:valid]
    assert result[:word_count].positive?
  end

  test "returns error for zero count" do
    result = Everyday::LoremIpsumCalculator.new(count: 0, unit: "paragraphs").call
    assert_not result[:valid]
    assert_includes result[:errors], "Count must be greater than zero"
  end

  test "returns error for negative count" do
    result = Everyday::LoremIpsumCalculator.new(count: -5, unit: "paragraphs").call
    assert_not result[:valid]
    assert_includes result[:errors], "Count must be greater than zero"
  end

  test "returns error for count over 100" do
    result = Everyday::LoremIpsumCalculator.new(count: 101, unit: "paragraphs").call
    assert_not result[:valid]
    assert_includes result[:errors], "Count must be 100 or less"
  end

  test "returns error for invalid unit" do
    result = Everyday::LoremIpsumCalculator.new(count: 5, unit: "chapters").call
    assert_not result[:valid]
    assert_includes result[:errors], "Unit must be paragraphs, sentences, or words"
  end

  test "coerces string count to integer" do
    result = Everyday::LoremIpsumCalculator.new(count: "3", unit: "paragraphs").call
    assert result[:valid]
    assert_equal 3, result[:count]
  end

  test "sentences start with capital letter and end with period" do
    result = Everyday::LoremIpsumCalculator.new(count: 1, unit: "sentences").call
    assert result[:valid]
    assert_match(/^[A-Z]/, result[:text])
    assert_match(/\.$/, result[:text])
  end
end
