require "test_helper"

class Everyday::GraphqlBuilderCalculatorTest < ActiveSupport::TestCase
  test "builds simple query" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", type_name: "users", fields: %w[id name email]
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:query], "query {"
    assert_includes result[:query], "users {"
    assert_includes result[:query], "id"
    assert_includes result[:query], "name"
    assert_includes result[:query], "email"
  end

  test "builds named query" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", operation_name: "GetUsers", type_name: "users", fields: %w[id]
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:query], "query GetUsers {"
  end

  test "builds mutation" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "mutation", type_name: "createUser", fields: %w[id name]
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:query], "mutation {"
  end

  test "builds query with arguments" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", type_name: "user",
      fields: %w[id name],
      arguments: [ { name: "id", value: "123", type: "int" } ]
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:query], "user(id: 123)"
    assert_equal true, result[:has_arguments]
  end

  test "handles string fields input" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", type_name: "users", fields: "id, name, email"
    ).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:field_count]
  end

  test "error when operation type is invalid" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "invalid", type_name: "users", fields: %w[id]
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Invalid operation type") }
  end

  test "error when type name is empty" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", type_name: "", fields: %w[id]
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Type name is required"
  end

  test "error when no fields provided" do
    result = Everyday::GraphqlBuilderCalculator.new(
      operation_type: "query", type_name: "users", fields: []
    ).call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "At least one field is required"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::GraphqlBuilderCalculator.new(operation_type: "query", type_name: "users", fields: %w[id])
    assert_equal [], calc.errors
  end
end
