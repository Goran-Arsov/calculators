require "test_helper"

class Everyday::CsvToPdfCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "parses simple CSV and returns rows with counts" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "name,age,city\nAlice,30,NYC\nBob,25,LA").call
    assert_equal true, result[:valid]
    assert_equal 3, result[:row_count]
    assert_equal 3, result[:col_count]
    assert_equal [ [ "name", "age", "city" ], [ "Alice", "30", "NYC" ], [ "Bob", "25", "LA" ] ], result[:rows]
  end

  test "parses tab-delimited data" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "a\tb\tc\n1\t2\t3", delimiter: "tab").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "parses semicolon-delimited data" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "x;y;z\n10;20;30", delimiter: ";").call
    assert_equal true, result[:valid]
    assert_equal 3, result[:col_count]
  end

  test "parses pipe-delimited data" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "a|b\n1|2", delimiter: "|").call
    assert_equal true, result[:valid]
    assert_equal 2, result[:col_count]
  end

  test "single row CSV" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "a,b,c").call
    assert_equal true, result[:valid]
    assert_equal 1, result[:row_count]
    assert_equal 3, result[:col_count]
  end

  test "string coercion of csv_text" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: 12345).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:row_count]
  end

  # --- Validation errors ---

  test "error when csv text is empty" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
    assert_includes result[:errors], "CSV text cannot be empty"
  end

  test "error when csv text is whitespace only" do
    result = Everyday::CsvToPdfCalculator.new(csv_text: "   \n  ").call
    assert_equal false, result[:valid]
    assert result[:errors].any?
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::CsvToPdfCalculator.new(csv_text: "a,b")
    assert_equal [], calc.errors
  end
end
