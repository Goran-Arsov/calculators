require "test_helper"

class Everyday::DatabaseSizeCalculatorTest < ActiveSupport::TestCase
  test "calculates size for simple integer-only table" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1000,
      columns: [{ type: "integer", avg_bytes: 0 }]
    ).call

    assert result[:valid]
    assert_equal 4, result[:bytes_per_row]
    # (4 + 23) * 1000 = 27_000
    assert_equal 27_000, result[:raw_table_size_bytes]
    # 27_000 * 1.3 = 35_100
    assert_equal 35_100, result[:with_index_size_bytes]
  end

  test "calculates size for mixed column types" do
    columns = [
      { type: "bigint", avg_bytes: 0 },       # 8
      { type: "varchar", avg_bytes: 50 },      # 50
      { type: "boolean", avg_bytes: 0 },       # 1
      { type: "timestamp", avg_bytes: 0 }      # 8
    ]
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 10_000,
      columns: columns
    ).call

    assert result[:valid]
    assert_equal 67, result[:bytes_per_row] # 8 + 50 + 1 + 8
    # (67 + 23) * 10_000 = 900_000
    assert_equal 900_000, result[:raw_table_size_bytes]
  end

  test "includes PostgreSQL row overhead of 23 bytes" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1,
      columns: [{ type: "integer", avg_bytes: 0 }]
    ).call

    assert result[:valid]
    assert_equal 27, result[:raw_row_bytes_with_overhead] # 4 + 23
  end

  test "adds 30% for index overhead" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1000,
      columns: [{ type: "integer", avg_bytes: 0 }]
    ).call

    assert result[:valid]
    raw = result[:raw_table_size_bytes]
    with_index = result[:with_index_size_bytes]
    assert_equal (raw * 1.3).round, with_index
  end

  test "handles all fixed-size types" do
    columns = [
      { type: "integer", avg_bytes: 0 },    # 4
      { type: "bigint", avg_bytes: 0 },      # 8
      { type: "boolean", avg_bytes: 0 },     # 1
      { type: "timestamp", avg_bytes: 0 },   # 8
      { type: "float", avg_bytes: 0 },       # 8
      { type: "uuid", avg_bytes: 0 }         # 16
    ]
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1,
      columns: columns
    ).call

    assert result[:valid]
    assert_equal 45, result[:bytes_per_row] # 4+8+1+8+8+16
  end

  test "handles varchar with avg_bytes" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 100,
      columns: [{ type: "varchar", avg_bytes: 255 }]
    ).call

    assert result[:valid]
    assert_equal 255, result[:bytes_per_row]
  end

  test "handles text with avg_bytes" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 100,
      columns: [{ type: "text", avg_bytes: 1000 }]
    ).call

    assert result[:valid]
    assert_equal 1000, result[:bytes_per_row]
  end

  test "formats output as KB" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 100,
      columns: [{ type: "integer", avg_bytes: 0 }]
    ).call

    assert result[:valid]
    # (4+23)*100 = 2700 bytes = 2.64 KB
    assert_match(/KB/, result[:formatted_raw_size])
  end

  test "formats output as MB for larger tables" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1_000_000,
      columns: [
        { type: "bigint", avg_bytes: 0 },
        { type: "varchar", avg_bytes: 100 }
      ]
    ).call

    assert result[:valid]
    assert_match(/MB|GB/, result[:formatted_with_index_size])
  end

  test "returns error for zero rows" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 0,
      columns: [{ type: "integer", avg_bytes: 0 }]
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "Number of rows must be greater than zero"
  end

  test "returns error for empty columns" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1000,
      columns: []
    ).call

    assert_not result[:valid]
    assert_includes result[:errors], "At least one column is required"
  end

  test "returns error for unknown column type" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1000,
      columns: [{ type: "unknown_type", avg_bytes: 0 }]
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unknown column type") }
  end

  test "returns error for varchar with zero avg_bytes" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 1000,
      columns: [{ type: "varchar", avg_bytes: 0 }]
    ).call

    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Average bytes must be positive") }
  end

  test "returns column count" do
    columns = [
      { type: "integer", avg_bytes: 0 },
      { type: "bigint", avg_bytes: 0 },
      { type: "boolean", avg_bytes: 0 }
    ]
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 100,
      columns: columns
    ).call

    assert result[:valid]
    assert_equal 3, result[:column_count]
  end

  test "handles very large row counts" do
    result = Everyday::DatabaseSizeCalculator.new(
      num_rows: 100_000_000,
      columns: [
        { type: "bigint", avg_bytes: 0 },
        { type: "varchar", avg_bytes: 100 },
        { type: "timestamp", avg_bytes: 0 }
      ]
    ).call

    assert result[:valid]
    assert_match(/GB/, result[:formatted_with_index_size])
  end
end
