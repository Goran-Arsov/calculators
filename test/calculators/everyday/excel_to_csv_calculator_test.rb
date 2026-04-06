require "test_helper"

class Everyday::ExcelToCsvCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "converts rows to CSV with comma delimiter" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ "name", "age" ], [ "Alice", "30" ], [ "Bob", "25" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3, result[:row_count]
    assert_equal 2, result[:col_count]
    assert_includes result[:csv_text], "name,age"
    assert_includes result[:csv_text], "Alice,30"
  end

  test "converts rows with tab delimiter" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ "a", "b" ], [ "1", "2" ] ],
      delimiter: "tab"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:csv_text], "a\tb"
  end

  test "converts rows with semicolon delimiter" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ "a", "b" ], [ "1", "2" ] ],
      delimiter: ";"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:csv_text], "a;b"
  end

  test "converts rows with pipe delimiter" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ "a", "b" ], [ "1", "2" ] ],
      delimiter: "|"
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:csv_text], "a|b"
  end

  test "quotes fields containing delimiter" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ "hello, world", "test" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:csv_text], '"hello, world"'
  end

  test "quotes fields containing double quotes" do
    result = Everyday::ExcelToCsvCalculator.new(
      rows: [ [ 'say "hi"', "test" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_includes result[:csv_text], '"say ""hi"""'
  end

  test "single row" do
    result = Everyday::ExcelToCsvCalculator.new(rows: [ [ "a", "b", "c" ] ]).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "returns delimiter in result" do
    result = Everyday::ExcelToCsvCalculator.new(rows: [ [ "a" ] ], delimiter: ";").call
    assert_equal ";", result[:delimiter]
  end

  # --- Validation errors ---

  test "error when rows is nil" do
    result = Everyday::ExcelToCsvCalculator.new(rows: nil).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No data provided"
  end

  test "error when rows is empty" do
    result = Everyday::ExcelToCsvCalculator.new(rows: []).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No data provided"
  end

  test "error when rows is not array of arrays" do
    result = Everyday::ExcelToCsvCalculator.new(rows: [ "a", "b" ]).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Data must be an array of arrays"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ExcelToCsvCalculator.new(rows: [ [ "a" ] ])
    assert_equal [], calc.errors
  end
end
