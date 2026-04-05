require "test_helper"

class Everyday::RemoveDuplicatesCalculatorTest < ActiveSupport::TestCase
  test "removes duplicate lines" do
    text = "apple\nbanana\napple\ncherry\nbanana"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal "apple\nbanana\ncherry", result[:unique_lines]
  end

  test "counts original lines" do
    text = "a\nb\na\nc"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 4, result[:original_line_count]
  end

  test "counts unique lines" do
    text = "a\nb\na\nc"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 3, result[:unique_line_count]
  end

  test "counts duplicates removed" do
    text = "a\nb\na\na\nc"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 2, result[:duplicates_removed]
  end

  test "preserves order of first occurrence" do
    text = "cherry\napple\nbanana\napple\ncherry"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal "cherry\napple\nbanana", result[:unique_lines]
  end

  test "handles text with no duplicates" do
    text = "alpha\nbeta\ngamma"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 0, result[:duplicates_removed]
    assert_equal text, result[:unique_lines]
  end

  test "returns error for empty text" do
    result = Everyday::RemoveDuplicatesCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles single line" do
    result = Everyday::RemoveDuplicatesCalculator.new(text: "only one line").call
    assert result[:valid]
    assert_equal 1, result[:unique_line_count]
    assert_equal 0, result[:duplicates_removed]
  end

  test "treats lines as case-sensitive" do
    text = "Hello\nhello\nHELLO"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 3, result[:unique_line_count]
    assert_equal 0, result[:duplicates_removed]
  end

  test "handles lines with trailing spaces as distinct" do
    text = "hello\nhello \nhello"
    result = Everyday::RemoveDuplicatesCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 2, result[:unique_line_count]
  end
end
