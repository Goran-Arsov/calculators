require "test_helper"

class Everyday::JsonToYamlCalculatorTest < ActiveSupport::TestCase
  test "converts simple JSON object to YAML" do
    result = Everyday::JsonToYamlCalculator.new(text: '{"name":"John","age":30}').call
    assert result[:valid]
    assert_includes result[:yaml], "name: John"
    assert_includes result[:yaml], "age: 30"
  end

  test "converts JSON array to YAML" do
    result = Everyday::JsonToYamlCalculator.new(text: "[1,2,3]").call
    assert result[:valid]
    assert_includes result[:yaml], "- 1"
    assert_equal "Array", result[:root_type]
  end

  test "converts nested JSON to YAML" do
    result = Everyday::JsonToYamlCalculator.new(text: '{"user":{"name":"John","age":30}}').call
    assert result[:valid]
    assert_includes result[:yaml], "user:"
    assert_includes result[:yaml], "name: John"
  end

  test "returns clean YAML without document separator" do
    result = Everyday::JsonToYamlCalculator.new(text: '{"a":1}').call
    assert result[:valid]
    assert_not result[:yaml_clean].start_with?("---")
  end

  test "returns size comparison" do
    text = '{"name":"John","age":30}'
    result = Everyday::JsonToYamlCalculator.new(text: text).call
    assert result[:valid]
    assert result[:json_size].positive?
    assert result[:yaml_size].positive?
  end

  test "counts keys" do
    result = Everyday::JsonToYamlCalculator.new(text: '{"a":1,"b":2,"c":3}').call
    assert result[:valid]
    assert_equal 3, result[:key_count]
  end

  test "returns error for invalid JSON" do
    result = Everyday::JsonToYamlCalculator.new(text: "{invalid}").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "returns error for empty text" do
    result = Everyday::JsonToYamlCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end
end
