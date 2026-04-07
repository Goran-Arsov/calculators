require "test_helper"

class Everyday::JsonValidatorCalculatorTest < ActiveSupport::TestCase
  test "validates correct JSON object" do
    result = Everyday::JsonValidatorCalculator.new(text: '{"name":"John"}').call
    assert result[:valid]
    assert result[:json_valid]
    assert_equal "Object", result[:root_type]
  end

  test "validates correct JSON array" do
    result = Everyday::JsonValidatorCalculator.new(text: "[1,2,3]").call
    assert result[:valid]
    assert result[:json_valid]
    assert_equal "Array", result[:root_type]
  end

  test "detects invalid JSON" do
    result = Everyday::JsonValidatorCalculator.new(text: "{invalid}").call
    assert result[:valid]
    assert_not result[:json_valid]
    assert result[:error_message].present?
  end

  test "counts keys in nested objects" do
    result = Everyday::JsonValidatorCalculator.new(text: '{"a":{"b":1,"c":2}}').call
    assert result[:valid]
    assert_equal 3, result[:key_count]
  end

  test "calculates nesting depth" do
    result = Everyday::JsonValidatorCalculator.new(text: '{"a":{"b":{"c":1}}}').call
    assert result[:valid]
    assert_equal 4, result[:nesting_depth]
  end

  test "returns formatted output" do
    result = Everyday::JsonValidatorCalculator.new(text: '{"a":1}').call
    assert result[:valid]
    assert_includes result[:formatted], "  \"a\": 1"
  end

  test "returns size in bytes" do
    text = '{"name":"John"}'
    result = Everyday::JsonValidatorCalculator.new(text: text).call
    assert result[:valid]
    assert_equal text.bytesize, result[:size_bytes]
  end

  test "returns error for empty text" do
    result = Everyday::JsonValidatorCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles empty object" do
    result = Everyday::JsonValidatorCalculator.new(text: "{}").call
    assert result[:valid]
    assert result[:json_valid]
    assert_equal 0, result[:key_count]
  end
end
