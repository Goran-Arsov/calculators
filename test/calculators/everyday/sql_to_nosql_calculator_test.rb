require "test_helper"

class Everyday::SqlToNosqlCalculatorTest < ActiveSupport::TestCase
  test "converts simple SELECT to find" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "SELECT * FROM users").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "db.users.find"
  end

  test "converts SELECT with WHERE clause" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "SELECT name FROM users WHERE age > 25").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "$gt"
    assert_includes result[:converted], "25"
  end

  test "converts SELECT with ORDER BY and LIMIT" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "SELECT * FROM users ORDER BY name LIMIT 10").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], ".sort"
    assert_includes result[:converted], ".limit(10)"
  end

  test "converts INSERT INTO to insertOne" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "INSERT INTO users (name, age) VALUES ('Alice', 30)").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "insertOne"
    assert_includes result[:converted], "name"
    assert_includes result[:converted], "Alice"
  end

  test "converts UPDATE to updateMany" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "UPDATE users SET name = 'Bob' WHERE id = 1").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "updateMany"
    assert_includes result[:converted], "$set"
  end

  test "converts DELETE to deleteMany" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "DELETE FROM users WHERE id = 1").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "deleteMany"
  end

  test "converts CREATE TABLE to createCollection" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "CREATE TABLE users (id INT, name VARCHAR)").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "createCollection"
  end

  test "converts DROP TABLE to drop" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "DROP TABLE users").call
    assert_equal true, result[:valid]
    assert_includes result[:converted], "db.users.drop()"
  end

  test "error when SQL is empty" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "SQL query is required"
  end

  test "error for unsupported target" do
    result = Everyday::SqlToNosqlCalculator.new(sql: "SELECT * FROM users", target: "cassandra").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported target") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::SqlToNosqlCalculator.new(sql: "SELECT * FROM users")
    assert_equal [], calc.errors
  end
end
