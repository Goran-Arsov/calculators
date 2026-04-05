require "test_helper"

class Everyday::RegexTesterCalculatorTest < ActiveSupport::TestCase
  test "finds simple matches" do
    result = Everyday::RegexTesterCalculator.new(pattern: "\\d+", test_string: "abc 123 def 456").call
    assert result[:valid]
    assert_equal 2, result[:match_count]
    assert_equal "123", result[:matches][0][:match]
    assert_equal "456", result[:matches][1][:match]
  end

  test "returns match positions" do
    result = Everyday::RegexTesterCalculator.new(pattern: "world", test_string: "hello world").call
    assert result[:valid]
    assert_equal 6, result[:matches][0][:index]
    assert_equal 5, result[:matches][0][:length]
  end

  test "captures groups" do
    result = Everyday::RegexTesterCalculator.new(pattern: "(\\w+)@(\\w+)", test_string: "user@host").call
    assert result[:valid]
    assert_equal [ "user", "host" ], result[:matches][0][:captures]
    assert result[:has_captures]
  end

  test "case insensitive flag works" do
    result = Everyday::RegexTesterCalculator.new(pattern: "hello", test_string: "HELLO world", flags: "i").call
    assert result[:valid]
    assert_equal 1, result[:match_count]
    assert_equal "HELLO", result[:matches][0][:match]
  end

  test "multiline flag works" do
    result = Everyday::RegexTesterCalculator.new(pattern: "^start", test_string: "end\nstart here", flags: "m").call
    assert result[:valid]
    assert_equal 1, result[:match_count]
  end

  test "returns error for invalid regex pattern" do
    result = Everyday::RegexTesterCalculator.new(pattern: "[invalid", test_string: "test").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid regex") }
  end

  test "returns error for empty pattern" do
    result = Everyday::RegexTesterCalculator.new(pattern: "", test_string: "test").call
    assert_not result[:valid]
    assert_includes result[:errors], "Pattern cannot be empty"
  end

  test "returns error for empty test string" do
    result = Everyday::RegexTesterCalculator.new(pattern: "\\d+", test_string: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Test string cannot be empty"
  end

  test "handles no matches" do
    result = Everyday::RegexTesterCalculator.new(pattern: "xyz", test_string: "hello world").call
    assert result[:valid]
    assert_equal 0, result[:match_count]
    assert_empty result[:matches]
  end

  test "handles special regex characters" do
    result = Everyday::RegexTesterCalculator.new(pattern: "\\.", test_string: "hello.world.test").call
    assert result[:valid]
    assert_equal 2, result[:match_count]
  end
end
