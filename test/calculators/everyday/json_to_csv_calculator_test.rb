require "test_helper"

class Everyday::JsonToCsvCalculatorTest < ActiveSupport::TestCase
  test "converts array of objects to CSV" do
    json = '[{"name":"Alice","age":"30"},{"name":"Bob","age":"25"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 2, result[:col_count]
    assert_equal %w[name age], result[:headers]
    assert_includes result[:csv_text], "name,age"
    assert_includes result[:csv_text], "Alice,30"
    assert_includes result[:csv_text], "Bob,25"
  end

  test "extracts union of all keys as headers" do
    json = '[{"a":"1","b":"2"},{"b":"3","c":"4"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_equal %w[a b c], result[:headers]
    assert_equal 3, result[:col_count]
    # Missing keys should produce empty values
    assert_includes result[:csv_text], "1,2,"
    assert_includes result[:csv_text], ",3,4"
  end

  test "uses tab delimiter" do
    json = '[{"name":"Alice","age":"30"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json, delimiter: "tab").call
    assert result[:valid]
    assert_includes result[:csv_text], "name\tage"
  end

  test "uses semicolon delimiter" do
    json = '[{"name":"Alice","age":"30"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json, delimiter: "semicolon").call
    assert result[:valid]
    assert_includes result[:csv_text], "name;age"
  end

  test "uses pipe delimiter" do
    json = '[{"name":"Alice","age":"30"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json, delimiter: "pipe").call
    assert result[:valid]
    assert_includes result[:csv_text], "name|age"
  end

  test "returns error for empty JSON" do
    result = Everyday::JsonToCsvCalculator.new(json: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "JSON cannot be empty"
  end

  test "returns error for invalid JSON" do
    result = Everyday::JsonToCsvCalculator.new(json: "{not valid json}").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid JSON") }
  end

  test "returns error for non-array JSON" do
    result = Everyday::JsonToCsvCalculator.new(json: '{"key":"value"}').call
    assert_not result[:valid]
    assert_includes result[:errors], "JSON must be an array of objects"
  end

  test "returns error for empty JSON array" do
    result = Everyday::JsonToCsvCalculator.new(json: "[]").call
    assert_not result[:valid]
    assert_includes result[:errors], "JSON array is empty"
  end

  test "returns error for array of non-objects" do
    result = Everyday::JsonToCsvCalculator.new(json: '["a","b","c"]').call
    assert_not result[:valid]
    assert_includes result[:errors], "All items in the JSON array must be objects"
  end

  test "returns error for unsupported delimiter" do
    result = Everyday::JsonToCsvCalculator.new(json: '[{"a":"1"}]', delimiter: "colon").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported delimiter") }
  end

  test "handles values containing commas with quoting" do
    json = '[{"name":"Doe, Jane","city":"New York"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_includes result[:csv_text], '"Doe, Jane"'
  end

  test "handles null values" do
    json = '[{"name":"Alice","age":null}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_equal 1, result[:row_count]
  end

  test "handles numeric values" do
    json = '[{"count":42,"price":9.99}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_includes result[:csv_text], "42"
    assert_includes result[:csv_text], "9.99"
  end

  test "handles single object array" do
    json = '[{"key":"value"}]'
    result = Everyday::JsonToCsvCalculator.new(json: json).call
    assert result[:valid]
    assert_equal 1, result[:row_count]
    assert_equal 1, result[:col_count]
    assert_equal %w[key], result[:headers]
  end
end
