require "test_helper"

class Everyday::TextDiffCalculatorTest < ActiveSupport::TestCase
  test "detects identical texts" do
    text = "Hello\nWorld"
    result = Everyday::TextDiffCalculator.new(text_a: text, text_b: text).call
    assert result[:valid]
    assert result[:identical]
    assert_equal 0, result[:additions]
    assert_equal 0, result[:removals]
  end

  test "detects added lines" do
    result = Everyday::TextDiffCalculator.new(text_a: "Hello", text_b: "Hello\nWorld").call
    assert result[:valid]
    assert_equal 1, result[:additions]
    assert_equal 0, result[:removals]
  end

  test "detects removed lines" do
    result = Everyday::TextDiffCalculator.new(text_a: "Hello\nWorld", text_b: "Hello").call
    assert result[:valid]
    assert_equal 0, result[:additions]
    assert_equal 1, result[:removals]
  end

  test "detects changed lines" do
    result = Everyday::TextDiffCalculator.new(text_a: "Hello\nWorld", text_b: "Hello\nEarth").call
    assert result[:valid]
    assert_equal 1, result[:additions]
    assert_equal 1, result[:removals]
    assert_equal 1, result[:unchanged]
  end

  test "counts total lines for both inputs" do
    result = Everyday::TextDiffCalculator.new(text_a: "A\nB\nC", text_b: "A\nB").call
    assert result[:valid]
    assert_equal 3, result[:total_lines_a]
    assert_equal 2, result[:total_lines_b]
  end

  test "returns error when both texts are empty" do
    result = Everyday::TextDiffCalculator.new(text_a: "", text_b: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Both texts cannot be empty"
  end

  test "handles one empty text" do
    result = Everyday::TextDiffCalculator.new(text_a: "Hello\nWorld", text_b: "").call
    assert result[:valid]
    assert_equal 2, result[:removals]
  end

  test "handles multiline diff with mixed changes" do
    text_a = "Line 1\nLine 2\nLine 3\nLine 4"
    text_b = "Line 1\nModified\nLine 3\nLine 5"
    result = Everyday::TextDiffCalculator.new(text_a: text_a, text_b: text_b).call
    assert result[:valid]
    assert_equal 2, result[:unchanged]
  end

  test "diff array contains type information" do
    result = Everyday::TextDiffCalculator.new(text_a: "A\nB", text_b: "A\nC").call
    assert result[:valid]
    types = result[:diff].map { |d| d[:type] }
    assert_includes types, :unchanged
    assert_includes types, :removed
    assert_includes types, :added
  end

  test "not identical when texts differ" do
    result = Everyday::TextDiffCalculator.new(text_a: "Hello", text_b: "World").call
    assert result[:valid]
    assert_not result[:identical]
  end
end
