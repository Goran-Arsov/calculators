require "test_helper"

class Everyday::CsvToExcelCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "parses simple CSV with commas" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a,b,c\n1,2,3").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:col_count]
    assert_equal 6, result[:cell_count]
    assert_equal [ [ "a", "b", "c" ], [ "1", "2", "3" ] ], result[:rows]
  end

  test "parses tab-delimited data" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a\tb\n1\t2", delimiter: "tab").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2, result[:row_count]
    assert_equal 2, result[:col_count]
  end

  test "parses semicolon-delimited data" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a;b;c\n1;2;3", delimiter: ";").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3, result[:col_count]
  end

  test "parses pipe-delimited data" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a|b\n1|2", delimiter: "|").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 2, result[:col_count]
  end

  test "handles quoted fields with embedded commas" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: '"hello, world",b\n1,2').call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "hello, world", result[:rows][0][0]
  end

  test "single row CSV" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a,b,c").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "uneven rows returns max col count" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "a,b,c\n1,2").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 3, result[:col_count]
  end

  test "string coercion of csv_text" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: 12345).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:row_count]
  end

  # --- Validation errors ---

  test "error when csv text is empty" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "CSV text cannot be empty"
  end

  test "error when csv text is whitespace only" do
    result = Everyday::CsvToExcelCalculator.new(csv_text: "   \n  ").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CsvToExcelCalculator.new(csv_text: "a,b")
    assert_equal [], calc.errors
  end
end
