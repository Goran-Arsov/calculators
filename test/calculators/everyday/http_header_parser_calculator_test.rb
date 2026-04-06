require "test_helper"

class Everyday::HttpHeaderParserCalculatorTest < ActiveSupport::TestCase
  test "parses basic headers" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "Content-Type: application/json\nCache-Control: no-cache"
    ).call

    assert result[:valid]
    assert_equal 2, result[:header_count]
    assert_equal "Content-Type", result[:headers][0][:name]
    assert_equal "application/json", result[:headers][0][:value]
    assert_equal "Cache-Control", result[:headers][1][:name]
    assert_equal "no-cache", result[:headers][1][:value]
  end

  test "skips HTTP status line" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "HTTP/1.1 200 OK\nContent-Type: text/html\nServer: nginx"
    ).call

    assert result[:valid]
    assert_equal 2, result[:header_count]
    assert_equal "Content-Type", result[:headers][0][:name]
    assert_equal "Server", result[:headers][1][:name]
  end

  test "handles header values with colons" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "Date: Thu, 01 Jan 2025 00:00:00 GMT"
    ).call

    assert result[:valid]
    assert_equal "Date", result[:headers][0][:name]
    assert_equal "Thu, 01 Jan 2025 00:00:00 GMT", result[:headers][0][:value]
  end

  test "flags malformed headers" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "Content-Type: text/html\nmalformed-line"
    ).call

    assert result[:valid]
    assert_equal 2, result[:header_count]
    assert result[:headers][1][:malformed]
  end

  test "identifies present security headers" do
    headers = [
      "Content-Security-Policy: default-src 'self'",
      "Strict-Transport-Security: max-age=31536000",
      "X-Frame-Options: DENY",
      "X-Content-Type-Options: nosniff"
    ].join("\n")

    result = Everyday::HttpHeaderParserCalculator.new(headers_text: headers).call

    assert result[:valid]
    assert_equal 4, result[:security_headers_present].size
    present_names = result[:security_headers_present].map { |h| h[:name] }
    assert_includes present_names, "Content-Security-Policy"
    assert_includes present_names, "Strict-Transport-Security"
    assert_includes present_names, "X-Frame-Options"
    assert_includes present_names, "X-Content-Type-Options"
  end

  test "identifies missing security headers" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "Content-Type: text/html"
    ).call

    assert result[:valid]
    assert_equal 10, result[:security_headers_missing].size
    assert_equal 0, result[:security_headers_present].size
  end

  test "calculates security score" do
    headers = [
      "Content-Security-Policy: default-src 'self'",
      "Strict-Transport-Security: max-age=31536000",
      "X-Frame-Options: DENY",
      "X-Content-Type-Options: nosniff",
      "X-XSS-Protection: 1; mode=block",
      "Referrer-Policy: strict-origin-when-cross-origin",
      "Permissions-Policy: camera=(), microphone=()",
      "X-Permitted-Cross-Domain-Policies: none",
      "Cross-Origin-Opener-Policy: same-origin",
      "Cross-Origin-Resource-Policy: same-origin"
    ].join("\n")

    result = Everyday::HttpHeaderParserCalculator.new(headers_text: headers).call

    assert result[:valid]
    assert_equal 100, result[:security_score]
    assert_equal "A", result[:security_grade]
  end

  test "grades security correctly for partial headers" do
    headers = [
      "Content-Security-Policy: default-src 'self'",
      "Strict-Transport-Security: max-age=31536000",
      "X-Frame-Options: DENY"
    ].join("\n")

    result = Everyday::HttpHeaderParserCalculator.new(headers_text: headers).call

    assert result[:valid]
    assert_equal 30, result[:security_score]
    assert_equal "D", result[:security_grade]
  end

  test "returns error for empty headers" do
    result = Everyday::HttpHeaderParserCalculator.new(headers_text: "").call

    assert_not result[:valid]
    assert_includes result[:errors], "Headers text cannot be empty"
  end

  test "returns error for whitespace-only input" do
    result = Everyday::HttpHeaderParserCalculator.new(headers_text: "   \n  \n  ").call

    assert_not result[:valid]
    assert_includes result[:errors], "Headers text cannot be empty"
  end

  test "handles headers with empty values" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "X-Custom-Header:"
    ).call

    assert result[:valid]
    assert_equal 1, result[:header_count]
    assert_equal "X-Custom-Header", result[:headers][0][:name]
    assert_equal "", result[:headers][0][:value]
  end

  test "skips blank lines between headers" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "Content-Type: text/html\n\nServer: nginx\n\n"
    ).call

    assert result[:valid]
    assert_equal 2, result[:header_count]
  end

  test "security headers are case-insensitive" do
    result = Everyday::HttpHeaderParserCalculator.new(
      headers_text: "content-security-policy: default-src 'self'\nSTRICT-TRANSPORT-SECURITY: max-age=31536000"
    ).call

    assert result[:valid]
    assert_equal 2, result[:security_headers_present].size
  end
end
