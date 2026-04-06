require "test_helper"

class Everyday::SqlFormatterCalculatorTest < ActiveSupport::TestCase
  test "uppercases SQL keywords" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users where active = true").call
    assert result[:valid]
    assert_includes result[:formatted], "SELECT"
    assert_includes result[:formatted], "FROM"
    assert_includes result[:formatted], "WHERE"
  end

  test "adds newlines before major clauses" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users where active = true").call
    assert result[:valid]
    lines = result[:formatted].split("\n")
    assert lines.any? { |l| l.strip.start_with?("SELECT") }
    assert lines.any? { |l| l.strip.start_with?("FROM") }
    assert lines.any? { |l| l.strip.start_with?("WHERE") }
  end

  test "indents AND and OR clauses" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users where active = true and age > 18 or role = 'admin'").call
    assert result[:valid]
    lines = result[:formatted].split("\n")
    and_line = lines.find { |l| l.strip.start_with?("AND") }
    or_line = lines.find { |l| l.strip.start_with?("OR") }
    assert and_line&.start_with?("  "), "AND should be indented"
    assert or_line&.start_with?("  "), "OR should be indented"
  end

  test "handles multi-word keywords like GROUP BY and ORDER BY" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select department, count(*) from employees group by department order by count(*) desc").call
    assert result[:valid]
    assert_includes result[:formatted], "GROUP BY"
    assert_includes result[:formatted], "ORDER BY"
  end

  test "handles JOIN clauses" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select u.name from users u inner join orders o on u.id = o.user_id").call
    assert result[:valid]
    assert_includes result[:formatted], "INNER JOIN"
  end

  test "preserves non-keyword identifiers in original case" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select userName from myTable").call
    assert result[:valid]
    assert_includes result[:formatted], "userName"
    assert_includes result[:formatted], "myTable"
  end

  test "returns keyword count" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users where active = true").call
    assert result[:valid]
    assert result[:keyword_count] > 0
  end

  test "returns line count" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users where active = true").call
    assert result[:valid]
    assert result[:line_count] > 1
  end

  test "returns original SQL" do
    sql = "select name from users"
    result = Everyday::SqlFormatterCalculator.new(sql: sql).call
    assert result[:valid]
    assert_equal sql, result[:original]
  end

  test "normalizes excessive whitespace" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select    name   from    users").call
    assert result[:valid]
    # Should not have multiple consecutive spaces within a line
    result[:formatted].split("\n").each do |line|
      assert_not_includes line.strip, "  ", "Line should not have double spaces: #{line}" unless line.strip.empty?
    end
  end

  test "returns error for empty SQL" do
    result = Everyday::SqlFormatterCalculator.new(sql: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "SQL cannot be empty"
  end

  test "returns error for whitespace-only SQL" do
    result = Everyday::SqlFormatterCalculator.new(sql: "   ").call
    assert_not result[:valid]
    assert_includes result[:errors], "SQL cannot be empty"
  end

  test "handles LIMIT and OFFSET" do
    result = Everyday::SqlFormatterCalculator.new(sql: "select name from users limit 10 offset 20").call
    assert result[:valid]
    assert_includes result[:formatted], "LIMIT"
    assert_includes result[:formatted], "OFFSET"
  end

  test "handles INSERT statement" do
    result = Everyday::SqlFormatterCalculator.new(sql: "insert into users (name, email) values ('John', 'john@example.com')").call
    assert result[:valid]
    assert_includes result[:formatted], "INSERT"
    assert_includes result[:formatted], "INTO"
    assert_includes result[:formatted], "VALUES"
  end

  test "handles UPDATE statement" do
    result = Everyday::SqlFormatterCalculator.new(sql: "update users set name = 'Jane' where id = 1").call
    assert result[:valid]
    assert_includes result[:formatted], "UPDATE"
    assert_includes result[:formatted], "SET"
    assert_includes result[:formatted], "WHERE"
  end
end
