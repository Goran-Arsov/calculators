require "test_helper"

class Everyday::MarkdownTableGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates markdown table with cell data" do
    cells = [ [ "Name", "Age" ], [ "Alice", "30" ], [ "Bob", "25" ] ]
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 3, columns: 2, cells: cells).call
    assert result[:valid]
    assert_equal 3, result[:row_count]
    assert_equal 2, result[:column_count]
    assert_includes result[:markdown], "| Name"
    assert_includes result[:markdown], "| Alice"
    assert_includes result[:markdown], "| Bob"
    assert_includes result[:markdown], "---"
  end

  test "generates table with empty cells when no data provided" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 2, columns: 3, cells: []).call
    assert result[:valid]
    assert_equal 2, result[:row_count]
    assert_equal 3, result[:column_count]
    lines = result[:markdown].split("\n")
    assert_equal 3, lines.length # header + separator + 1 data row
  end

  test "generates single cell table" do
    cells = [ [ "Value" ] ]
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 1, columns: 1, cells: cells).call
    assert result[:valid]
    assert_equal 1, result[:row_count]
    assert_equal 1, result[:column_count]
    lines = result[:markdown].split("\n")
    assert_equal 2, lines.length # header + separator, no data rows when rows=1
  end

  test "pads columns to consistent width" do
    cells = [ [ "A", "Long Header" ], [ "X", "Y" ] ]
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 2, columns: 2, cells: cells).call
    assert result[:valid]
    # The separator row should match header width
    lines = result[:markdown].split("\n")
    assert_equal lines[0].length, lines[1].length
  end

  test "returns error for rows below minimum" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 0, columns: 2).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Rows must be") }
  end

  test "returns error for rows above maximum" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 21, columns: 2).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Rows must be") }
  end

  test "returns error for columns below minimum" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 2, columns: 0).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Columns must be") }
  end

  test "returns error for columns above maximum" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 2, columns: 21).call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Columns must be") }
  end

  test "accepts max valid rows and columns" do
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 20, columns: 20).call
    assert result[:valid]
    assert_equal 20, result[:row_count]
    assert_equal 20, result[:column_count]
  end

  test "handles partial cell data gracefully" do
    cells = [ [ "Header1", "Header2" ] ]
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 3, columns: 2, cells: cells).call
    assert result[:valid]
    assert_equal 3, result[:row_count]
    # Missing rows should use empty strings
    assert_includes result[:markdown], "|"
  end

  test "markdown output has proper pipe-delimited format" do
    cells = [ [ "A", "B" ], [ "1", "2" ] ]
    result = Everyday::MarkdownTableGeneratorCalculator.new(rows: 2, columns: 2, cells: cells).call
    assert result[:valid]
    lines = result[:markdown].split("\n")
    lines.each do |line|
      assert line.start_with?("|"), "Each line should start with pipe"
      assert line.end_with?("|"), "Each line should end with pipe"
    end
  end
end
