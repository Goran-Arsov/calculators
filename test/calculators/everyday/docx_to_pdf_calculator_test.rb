require "test_helper"

class Everyday::DocxToPdfCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "returns valid result with paragraph and word counts" do
    result = Everyday::DocxToPdfCalculator.new(
      paragraphs: [
        { text: "Hello world" },
        { text: "This is a test paragraph" },
        { text: "Final paragraph here" }
      ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:paragraph_count]
    assert_equal 10, result[:word_count]
  end

  test "handles single paragraph" do
    result = Everyday::DocxToPdfCalculator.new(
      paragraphs: [{ text: "One single paragraph with five words" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:paragraph_count]
    assert_equal 6, result[:word_count]
  end

  test "handles paragraph with single word" do
    result = Everyday::DocxToPdfCalculator.new(
      paragraphs: [{ text: "Hello" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:paragraph_count]
    assert_equal 1, result[:word_count]
  end

  test "handles paragraphs with empty text" do
    result = Everyday::DocxToPdfCalculator.new(
      paragraphs: [{ text: "" }, { text: "Some words" }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 2, result[:paragraph_count]
    assert_equal 2, result[:word_count]
  end

  test "handles paragraphs with extra whitespace" do
    result = Everyday::DocxToPdfCalculator.new(
      paragraphs: [{ text: "  multiple   spaces   here  " }]
    ).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:paragraph_count]
    assert_equal 3, result[:word_count]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::DocxToPdfCalculator.new(paragraphs: [{ text: "test" }])
    assert_equal [], calc.errors
  end

  # --- Validation errors ---

  test "error when paragraphs is nil" do
    result = Everyday::DocxToPdfCalculator.new(paragraphs: nil).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No content provided"
  end

  test "error when paragraphs is empty" do
    result = Everyday::DocxToPdfCalculator.new(paragraphs: []).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No content provided"
  end

  test "error when paragraphs is not an array" do
    result = Everyday::DocxToPdfCalculator.new(paragraphs: "not an array").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Content must be an array"
  end
end
