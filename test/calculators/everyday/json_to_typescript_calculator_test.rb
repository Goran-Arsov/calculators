require "test_helper"

class Everyday::JsonToTypescriptCalculatorTest < ActiveSupport::TestCase
  test "generates interface from simple object" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"name":"John","age":30}').call
    assert result[:valid]
    assert_includes result[:typescript], "interface Root"
    assert_includes result[:typescript], "name: string;"
    assert_includes result[:typescript], "age: number;"
  end

  test "generates nested interfaces" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"user":{"name":"John","active":true}}').call
    assert result[:valid]
    assert_includes result[:typescript], "interface Root"
    assert_includes result[:typescript], "interface User"
    assert result[:interface_count] >= 2
  end

  test "handles arrays of objects" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"users":[{"name":"John"}]}').call
    assert result[:valid]
    assert_includes result[:typescript], "User[]"
  end

  test "handles arrays of primitives" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"tags":["a","b"]}').call
    assert result[:valid]
    assert_includes result[:typescript], "string[]"
  end

  test "handles null values" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"value":null}').call
    assert result[:valid]
    assert_includes result[:typescript], "null"
  end

  test "handles boolean values" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"active":true}').call
    assert result[:valid]
    assert_includes result[:typescript], "boolean"
  end

  test "uses custom root name" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '{"name":"test"}', root_name: "Config").call
    assert result[:valid]
    assert_includes result[:typescript], "interface Config"
  end

  test "detects root array" do
    result = Everyday::JsonToTypescriptCalculator.new(text: '[{"name":"John"}]').call
    assert result[:valid]
    assert_equal "Array", result[:root_type]
  end

  test "returns error for invalid JSON" do
    result = Everyday::JsonToTypescriptCalculator.new(text: "{invalid}").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "returns error for empty text" do
    result = Everyday::JsonToTypescriptCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end
end
