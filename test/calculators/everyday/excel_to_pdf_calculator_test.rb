require "test_helper"

class Everyday::ExcelToPdfCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "returns valid result with row and column counts" do
    result = Everyday::ExcelToPdfCalculator.new(
      rows: [ [ "Name", "Age", "City" ], [ "Alice", "30", "NYC" ], [ "Bob", "25", "LA" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "handles single row" do
    result = Everyday::ExcelToPdfCalculator.new(
      rows: [ [ "A", "B", "C", "D" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:row_count]
    assert_equal 4, result[:col_count]
  end

  test "handles rows with different lengths and uses max" do
    result = Everyday::ExcelToPdfCalculator.new(
      rows: [ [ "A", "B" ], [ "C", "D", "E" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "handles single cell" do
    result = Everyday::ExcelToPdfCalculator.new(
      rows: [ [ "Hello" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:row_count]
    assert_equal 1, result[:col_count]
  end

  test "handles rows with empty strings" do
    result = Everyday::ExcelToPdfCalculator.new(
      rows: [ [ "", "", "" ], [ "A", "", "B" ] ]
    ).call
    assert_equal true, result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::ExcelToPdfCalculator.new(rows: [ [ "A" ] ])
    assert_equal [], calc.errors
  end

  # --- Validation errors ---

  test "error when rows is nil" do
    result = Everyday::ExcelToPdfCalculator.new(rows: nil).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No data provided"
  end

  test "error when rows is empty" do
    result = Everyday::ExcelToPdfCalculator.new(rows: []).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "No data provided"
  end

  test "error when rows is not array of arrays" do
    result = Everyday::ExcelToPdfCalculator.new(rows: [ "a", "b" ]).call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "Data must be an array of arrays"
  end
end
