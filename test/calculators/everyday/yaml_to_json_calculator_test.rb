require "test_helper"

class Everyday::YamlToJsonCalculatorTest < ActiveSupport::TestCase
  test "converts simple YAML to JSON" do
    yaml = "name: John\nage: 30\ncity: New York"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    assert_equal :yaml_to_json, result[:direction]
    parsed = JSON.parse(result[:output])
    assert_equal "John", parsed["name"]
    assert_equal 30, parsed["age"]
    assert_equal "New York", parsed["city"]
  end

  test "converts nested YAML to JSON" do
    yaml = "person:\n  name: John\n  address:\n    city: NYC\n    zip: '10001'"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "NYC", parsed["person"]["address"]["city"]
    assert_equal "10001", parsed["person"]["address"]["zip"]
  end

  test "converts YAML with arrays to JSON" do
    yaml = "colors:\n  - red\n  - green\n  - blue"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal %w[red green blue], parsed["colors"]
  end

  test "converts JSON to YAML" do
    json = '{"name": "John", "age": 30}'
    result = Everyday::YamlToJsonCalculator.new(text: json, direction: :json_to_yaml).call
    assert result[:valid]
    assert_equal :json_to_yaml, result[:direction]
    assert_includes result[:output], "name"
    assert_includes result[:output], "John"
  end

  test "returns error for empty text" do
    result = Everyday::YamlToJsonCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for invalid YAML" do
    yaml = "key: [invalid: yaml: here"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid YAML") }
  end

  test "returns error for invalid JSON in json_to_yaml direction" do
    result = Everyday::YamlToJsonCalculator.new(text: "{invalid}", direction: :json_to_yaml).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "returns error for invalid direction" do
    result = Everyday::YamlToJsonCalculator.new(text: "key: value", direction: :invalid).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid direction") }
  end

  test "reports input and output line counts" do
    yaml = "name: John\nage: 30"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    assert_equal 2, result[:input_lines]
    assert result[:output_lines] > 0
  end

  test "handles YAML boolean values" do
    yaml = "active: true\ndeleted: false"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal true, parsed["active"]
    assert_equal false, parsed["deleted"]
  end

  test "handles YAML null values" do
    yaml = "value: null\nother: ~"
    result = Everyday::YamlToJsonCalculator.new(text: yaml).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_nil parsed["value"]
    assert_nil parsed["other"]
  end

  test "handles whitespace-only text" do
    result = Everyday::YamlToJsonCalculator.new(text: "   \n  ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end
end
