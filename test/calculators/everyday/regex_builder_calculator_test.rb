require "test_helper"

class Everyday::RegexBuilderCalculatorTest < ActiveSupport::TestCase
  test "finds simple matches with positions" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "\\d+", test_text: "abc 123 def 456").call
    assert result[:valid]
    assert_equal 2, result[:match_count]
    assert_equal "123", result[:matches][0][:text]
    assert_equal 4, result[:matches][0][:start_position]
    assert_equal 7, result[:matches][0][:end_position]
    assert_equal "456", result[:matches][1][:text]
    assert_equal 12, result[:matches][1][:start_position]
    assert_equal 15, result[:matches][1][:end_position]
  end

  test "captures groups" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "(\\w+)@(\\w+)", test_text: "user@host").call
    assert result[:valid]
    assert_equal 1, result[:match_count]
    assert_equal 2, result[:matches][0][:groups].size
    assert_equal "user", result[:matches][0][:groups][0][:text]
    assert_equal 1, result[:matches][0][:groups][0][:index]
    assert_equal "host", result[:matches][0][:groups][1][:text]
    assert_equal 2, result[:matches][0][:groups][1][:index]
    assert result[:has_groups]
  end

  test "case insensitive flag works" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "hello", test_text: "HELLO world", flags: "i").call
    assert result[:valid]
    assert_equal 1, result[:match_count]
    assert_equal "HELLO", result[:matches][0][:text]
  end

  test "multiline flag works" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "^start", test_text: "end\nstart here", flags: "m").call
    assert result[:valid]
    assert_equal 1, result[:match_count]
    assert_equal "start", result[:matches][0][:text]
  end

  test "returns flags in result" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "test", test_text: "test", flags: "im").call
    assert result[:valid]
    assert_equal "im", result[:flags]
  end

  test "returns pattern_valid for valid patterns" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "\\d+", test_text: "123").call
    assert result[:valid]
    assert result[:pattern_valid]
  end

  test "returns error for invalid regex pattern" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "[invalid", test_text: "test").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid regex") }
  end

  test "returns error for empty pattern" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "", test_text: "test").call
    assert_not result[:valid]
    assert_includes result[:errors], "Pattern cannot be empty"
  end

  test "returns error for empty test text" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "\\d+", test_text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Test text cannot be empty"
  end

  test "returns error for whitespace-only pattern" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "   ", test_text: "test").call
    assert_not result[:valid]
    assert_includes result[:errors], "Pattern cannot be empty"
  end

  test "handles no matches" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "xyz", test_text: "hello world").call
    assert result[:valid]
    assert_equal 0, result[:match_count]
    assert_empty result[:matches]
    assert_not result[:has_groups]
  end

  test "handles multiple capture groups across multiple matches" do
    result = Everyday::RegexBuilderCalculator.new(
      pattern: "(\\w+)=(\\w+)",
      test_text: "a=1 b=2 c=3"
    ).call
    assert result[:valid]
    assert_equal 3, result[:match_count]
    assert_equal "a", result[:matches][0][:groups][0][:text]
    assert_equal "1", result[:matches][0][:groups][1][:text]
    assert_equal "b", result[:matches][1][:groups][0][:text]
    assert_equal "2", result[:matches][1][:groups][1][:text]
  end

  test "handles special regex characters" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "\\.", test_text: "hello.world.test").call
    assert result[:valid]
    assert_equal 2, result[:match_count]
  end

  test "returns pattern in result" do
    result = Everyday::RegexBuilderCalculator.new(pattern: "\\d+", test_text: "123").call
    assert result[:valid]
    assert_equal "\\d+", result[:pattern]
  end
end
