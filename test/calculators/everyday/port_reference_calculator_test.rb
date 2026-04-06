require "test_helper"

class Everyday::PortReferenceCalculatorTest < ActiveSupport::TestCase
  # --- Happy path ---

  test "finds port by number" do
    result = Everyday::PortReferenceCalculator.new(query: "22").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:result_count]
    assert_equal "SSH", result[:results].first[:service]
    assert_equal 22, result[:results].first[:port]
    assert_equal "TCP", result[:results].first[:protocol]
    assert_equal "remote_access", result[:results].first[:category]
  end

  test "finds port by service name" do
    result = Everyday::PortReferenceCalculator.new(query: "SSH").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:result_count] >= 1
    assert result[:results].any? { |r| r[:service] == "SSH" }
  end

  test "search is case insensitive" do
    result = Everyday::PortReferenceCalculator.new(query: "ssh").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:result_count] >= 1
    assert result[:results].any? { |r| r[:service] == "SSH" }
  end

  test "finds HTTP on port 80" do
    result = Everyday::PortReferenceCalculator.new(query: "80").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 1, result[:result_count]
    assert_equal "HTTP", result[:results].first[:service]
  end

  test "finds HTTPS on port 443" do
    result = Everyday::PortReferenceCalculator.new(query: "443").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "HTTPS", result[:results].first[:service]
  end

  test "finds PostgreSQL on port 5432" do
    result = Everyday::PortReferenceCalculator.new(query: "5432").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "PostgreSQL", result[:results].first[:service]
    assert_equal "database", result[:results].first[:category]
  end

  test "finds multiple results for partial name match" do
    result = Everyday::PortReferenceCalculator.new(query: "SMTP").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:result_count] >= 3 # SMTP, SMTPS, SMTP Submission
  end

  test "searches in description text" do
    result = Everyday::PortReferenceCalculator.new(query: "encryption").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:result_count] >= 1
  end

  test "wildcard returns all ports" do
    result = Everyday::PortReferenceCalculator.new(query: "*").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal Everyday::PortReferenceCalculator::PORTS.size, result[:result_count]
  end

  test "results are sorted by port number" do
    result = Everyday::PortReferenceCalculator.new(query: "database").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    ports = result[:results].map { |r| r[:port] }
    assert_equal ports.sort, ports
  end

  test "returns categories list" do
    result = Everyday::PortReferenceCalculator.new(query: "80").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert result[:categories].is_a?(Array)
    assert_includes result[:categories], "web"
    assert_includes result[:categories], "database"
    assert_includes result[:categories], "email"
  end

  test "returns empty results for unknown port" do
    result = Everyday::PortReferenceCalculator.new(query: "99999").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0, result[:result_count]
    assert_equal [], result[:results]
  end

  test "returns empty results for unknown service name" do
    result = Everyday::PortReferenceCalculator.new(query: "zzzznonexistent").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal 0, result[:result_count]
  end

  test "finds DNS on port 53 with Both protocol" do
    result = Everyday::PortReferenceCalculator.new(query: "53").call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "DNS", result[:results].first[:service]
    assert_equal "Both", result[:results].first[:protocol]
  end

  test "string coercion works" do
    result = Everyday::PortReferenceCalculator.new(query: 443).call
    assert_equal true, result[:valid]
    assert_nil result[:errors]
    assert_equal "HTTPS", result[:results].first[:service]
  end

  # --- Validation errors ---

  test "error when query is empty" do
    result = Everyday::PortReferenceCalculator.new(query: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Search query cannot be empty"
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::PortReferenceCalculator.new(query: "80")
    assert_equal [], calc.errors
  end
end
