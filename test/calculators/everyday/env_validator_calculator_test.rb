require "test_helper"

class Everyday::EnvValidatorCalculatorTest < ActiveSupport::TestCase
  test "parses valid .env content" do
    content = "DATABASE_URL=postgres://localhost/mydb\nRAILS_ENV=production\nPORT=3000"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:total_variables]
    assert_equal 0, result[:error_count]
    assert_equal 0, result[:warning_count]
  end

  test "returns variable details with line numbers" do
    content = "APP_NAME=myapp\nDEBUG=true"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]

    first = result[:variables].first
    assert_equal "APP_NAME", first[:key]
    assert_equal "myapp", first[:value]
    assert_equal 1, first[:line]
    assert_equal "valid", first[:status]
  end

  test "detects empty values" do
    content = "DATABASE_URL=\nAPP_NAME=myapp"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:warning_count]
    assert result[:warnings].any? { |w| w[:type] == "empty_value" }
  end

  test "detects unquoted spaces" do
    content = "GREETING=hello world"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert result[:warnings].any? { |w| w[:type] == "unquoted_spaces" }
  end

  test "does not warn for quoted values with spaces" do
    content = 'GREETING="hello world"'
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_not result[:warnings].any? { |w| w[:type] == "unquoted_spaces" }
  end

  test "detects duplicate keys" do
    content = "API_KEY=abc123\nDEBUG=true\nAPI_KEY=xyz789"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert result[:error_count] > 0
    assert result[:line_errors].any? { |e| e[:type] == "duplicate" }
  end

  test "detects missing equals sign" do
    content = "VALID_KEY=value\nINVALID_LINE\nANOTHER_KEY=value"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert result[:line_errors].any? { |e| e[:type] == "missing_equals" }
    assert_equal 2, result[:total_variables]
  end

  test "detects commented-out variables" do
    content = "# DATABASE_URL=postgres://localhost/mydb\nAPP_NAME=myapp"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert result[:warnings].any? { |w| w[:type] == "commented_out" }
    assert_equal 1, result[:total_variables]
  end

  test "detects sensitive keys" do
    content = "DB_PASSWORD=secret123\nAPI_KEY=abc\nSECRET_TOKEN=xyz"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal 3, result[:sensitive_count]
    assert result[:warnings].any? { |w| w[:type] == "sensitive" }
  end

  test "skips empty lines" do
    content = "APP_NAME=myapp\n\n\nDEBUG=true"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal 2, result[:total_variables]
  end

  test "skips pure comment lines without variable pattern" do
    content = "# This is a comment\nAPP_NAME=myapp"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal 1, result[:total_variables]
    assert_equal 0, result[:warning_count]
  end

  test "handles values with equals signs" do
    content = "CONNECTION=postgres://user:pass@host/db?opt=val"
    result = Everyday::EnvValidatorCalculator.new(content: content).call
    assert_equal true, result[:valid]
    assert_equal "postgres://user:pass@host/db?opt=val", result[:variables].first[:value]
  end

  # --- Validation errors ---

  test "error when content is empty" do
    result = Everyday::EnvValidatorCalculator.new(content: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Content cannot be empty"
  end

  test "error when content is whitespace only" do
    result = Everyday::EnvValidatorCalculator.new(content: "   \n  \n  ").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Content cannot be empty"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::EnvValidatorCalculator.new(content: "KEY=val")
    assert_equal [], calc.errors
  end
end
