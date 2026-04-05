require "test_helper"

class Everyday::JsonFormatterCalculatorTest < ActiveSupport::TestCase
  test "formats valid JSON with indentation" do
    result = Everyday::JsonFormatterCalculator.new(text: '{"name":"John","age":30}').call
    assert result[:valid]
    assert_includes result[:formatted], "  \"name\": \"John\""
  end

  test "minifies JSON" do
    text = "{\n  \"name\": \"John\",\n  \"age\": 30\n}"
    result = Everyday::JsonFormatterCalculator.new(text: text).call
    assert result[:valid]
    assert_equal '{"name":"John","age":30}', result[:minified]
  end

  test "counts top-level and nested keys" do
    text = '{"name":"John","address":{"city":"NYC","zip":"10001"}}'
    result = Everyday::JsonFormatterCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 4, result[:key_count]
  end

  test "calculates nesting depth" do
    text = '{"a":{"b":{"c":1}}}'
    result = Everyday::JsonFormatterCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 4, result[:nesting_depth]
  end

  test "detects array as root element" do
    result = Everyday::JsonFormatterCalculator.new(text: '[1,2,3]').call
    assert result[:valid]
    assert result[:is_array]
    assert_not result[:is_object]
  end

  test "detects object as root element" do
    result = Everyday::JsonFormatterCalculator.new(text: '{"a":1}').call
    assert result[:valid]
    assert result[:is_object]
    assert_not result[:is_array]
  end

  test "returns error for invalid JSON" do
    result = Everyday::JsonFormatterCalculator.new(text: '{invalid}').call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "returns error for empty text" do
    result = Everyday::JsonFormatterCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "handles deeply nested arrays" do
    text = '[[[[1]]]]'
    result = Everyday::JsonFormatterCalculator.new(text: text).call
    assert result[:valid]
    assert_equal 5, result[:nesting_depth]
  end

  test "handles empty object" do
    result = Everyday::JsonFormatterCalculator.new(text: '{}').call
    assert result[:valid]
    assert_equal 0, result[:key_count]
    assert_equal 1, result[:nesting_depth]
  end
end
