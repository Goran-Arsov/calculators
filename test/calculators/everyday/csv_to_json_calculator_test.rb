require "test_helper"

class Everyday::CsvToJsonCalculatorTest < ActiveSupport::TestCase
  test "converts CSV with headers to JSON objects" do
    csv = "name,age,city\nJohn,30,New York\nJane,25,LA"
    result = Everyday::CsvToJsonCalculator.new(text: csv).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal 2, parsed.length
    assert_equal "John", parsed[0]["name"]
    assert_equal "30", parsed[0]["age"]
    assert_equal "LA", parsed[1]["city"]
  end

  test "converts CSV without headers to JSON arrays" do
    csv = "John,30,New York\nJane,25,LA"
    result = Everyday::CsvToJsonCalculator.new(text: csv, has_headers: false).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal 2, parsed.length
    assert_equal %w[John 30 New\ York], parsed[0]
    assert_nil result[:headers]
    assert_equal false, result[:has_headers]
  end

  test "reports row and column counts with headers" do
    csv = "a,b,c\n1,2,3\n4,5,6"
    result = Everyday::CsvToJsonCalculator.new(text: csv).call
    assert result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:column_count]
    assert_equal %w[a b c], result[:headers]
  end

  test "uses tab delimiter" do
    csv = "name\tage\nJohn\t30"
    result = Everyday::CsvToJsonCalculator.new(text: csv, delimiter: "tab").call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "John", parsed[0]["name"]
    assert_equal "30", parsed[0]["age"]
  end

  test "uses semicolon delimiter" do
    csv = "name;age\nJohn;30"
    result = Everyday::CsvToJsonCalculator.new(text: csv, delimiter: "semicolon").call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "John", parsed[0]["name"]
  end

  test "uses pipe delimiter" do
    csv = "name|age\nJohn|30"
    result = Everyday::CsvToJsonCalculator.new(text: csv, delimiter: "pipe").call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "John", parsed[0]["name"]
  end

  test "returns error for empty text" do
    result = Everyday::CsvToJsonCalculator.new(text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Text cannot be empty"
  end

  test "returns error for unsupported delimiter" do
    result = Everyday::CsvToJsonCalculator.new(text: "a,b", delimiter: "colon").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported delimiter") }
  end

  test "returns error for headers only with no data rows" do
    result = Everyday::CsvToJsonCalculator.new(text: "name,age,city").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("no data rows") }
  end

  test "handles quoted fields with commas" do
    csv = "name,address\nJohn,\"123 Main St, Apt 4\""
    result = Everyday::CsvToJsonCalculator.new(text: csv).call
    assert result[:valid]
    parsed = JSON.parse(result[:output])
    assert_equal "123 Main St, Apt 4", parsed[0]["address"]
  end

  test "handles has_headers as string 'true'" do
    csv = "name,age\nJohn,30"
    result = Everyday::CsvToJsonCalculator.new(text: csv, has_headers: "true").call
    assert result[:valid]
    assert_equal true, result[:has_headers]
  end

  test "handles has_headers as string 'false'" do
    csv = "John,30\nJane,25"
    result = Everyday::CsvToJsonCalculator.new(text: csv, has_headers: "false").call
    assert result[:valid]
    assert_equal false, result[:has_headers]
  end

  test "handles single column CSV" do
    csv = "name\nJohn\nJane"
    result = Everyday::CsvToJsonCalculator.new(text: csv).call
    assert result[:valid]
    assert_equal 1, result[:column_count]
  end
end
