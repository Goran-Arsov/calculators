require "test_helper"

class Everyday::CorsCheckerCalculatorTest < ActiveSupport::TestCase
  test "detects CORS headers" do
    headers = [
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Methods: GET, POST"
    ].join("\n")

    result = Everyday::CorsCheckerCalculator.new(headers_text: headers).call
    assert result[:valid]
    assert result[:cors_enabled]
    assert_equal "*", result[:cors_headers]["access-control-allow-origin"]
    assert_equal "GET, POST", result[:cors_headers]["access-control-allow-methods"]
  end

  test "parses allowed origins list" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: https://example.com"
    ).call

    assert result[:valid]
    assert_equal [ "https://example.com" ], result[:allowed_origins]
  end

  test "parses allowed methods list" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Methods: GET, POST, PUT, DELETE"
    ).call

    assert result[:valid]
    assert_equal %w[GET POST PUT DELETE], result[:allowed_methods]
  end

  test "parses allowed headers list" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Headers: Content-Type, Authorization"
    ).call

    assert result[:valid]
    assert_equal %w[Content-Type Authorization], result[:allowed_headers]
  end

  test "detects credentials" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Credentials: true"
    ).call

    assert result[:valid]
    assert result[:allow_credentials]
  end

  test "parses max-age" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Max-Age: 86400"
    ).call

    assert result[:valid]
    assert_equal 86_400, result[:max_age]
  end

  test "parses expose-headers" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Expose-Headers: X-Custom, X-Request-Id"
    ).call

    assert result[:valid]
    assert_equal %w[X-Custom X-Request-Id], result[:exposed_headers]
  end

  test "detects no CORS headers" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Content-Type: text/html\nServer: nginx"
    ).call

    assert result[:valid]
    assert_not result[:cors_enabled]
    assert_empty result[:cors_headers]
  end

  test "warns about wildcard origin with credentials" do
    headers = [
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Credentials: true"
    ].join("\n")

    result = Everyday::CorsCheckerCalculator.new(headers_text: headers).call
    assert result[:valid]
    assert result[:warnings].any? { |w| w.include?("Wildcard origin") && w.include?("credentials") }
  end

  test "warns about wildcard origin" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: *"
    ).call

    assert result[:valid]
    assert result[:warnings].any? { |w| w.include?("Wildcard origin") && w.include?("any website") }
  end

  test "warns about missing Vary Origin header" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: https://example.com"
    ).call

    assert result[:valid]
    assert result[:warnings].any? { |w| w.include?("Vary: Origin") }
  end

  test "no Vary warning when Vary Origin is present" do
    headers = [
      "Access-Control-Allow-Origin: https://example.com",
      "Vary: Origin"
    ].join("\n")

    result = Everyday::CorsCheckerCalculator.new(headers_text: headers).call
    assert result[:valid]
    assert_not result[:warnings].any? { |w| w.include?("Vary: Origin") }
  end

  test "warns about excessive max-age" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Max-Age: 604800"
    ).call

    assert result[:valid]
    assert result[:warnings].any? { |w| w.include?("24 hours") }
  end

  test "test scenario passes when origin matches" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: https://myapp.com",
      test_origin: "https://myapp.com"
    ).call

    assert result[:valid]
    assert result[:test_result][:pass]
  end

  test "test scenario fails when origin does not match" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: https://other.com",
      test_origin: "https://myapp.com"
    ).call

    assert result[:valid]
    assert_not result[:test_result][:pass]
  end

  test "test scenario passes with wildcard origin" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: *",
      test_origin: "https://anything.com"
    ).call

    assert result[:valid]
    assert result[:test_result][:pass]
  end

  test "test scenario checks method" do
    headers = [
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Methods: GET, POST"
    ].join("\n")

    result = Everyday::CorsCheckerCalculator.new(
      headers_text: headers,
      test_method: "DELETE"
    ).call

    assert result[:valid]
    assert_not result[:test_result][:pass]
  end

  test "test scenario checks custom headers" do
    headers = [
      "Access-Control-Allow-Origin: *",
      "Access-Control-Allow-Headers: Content-Type, Authorization"
    ].join("\n")

    result = Everyday::CorsCheckerCalculator.new(
      headers_text: headers,
      test_headers: "Authorization"
    ).call

    assert result[:valid]
    assert result[:test_result][:pass]
  end

  test "no test result when no test inputs provided" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "Access-Control-Allow-Origin: *"
    ).call

    assert result[:valid]
    assert_nil result[:test_result]
  end

  test "skips HTTP status line" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "HTTP/1.1 200 OK\nAccess-Control-Allow-Origin: *"
    ).call

    assert result[:valid]
    assert result[:cors_enabled]
  end

  test "returns error for empty headers" do
    result = Everyday::CorsCheckerCalculator.new(headers_text: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "Headers text cannot be empty"
  end

  test "returns error for whitespace-only headers" do
    result = Everyday::CorsCheckerCalculator.new(headers_text: "   \n  ").call
    assert_not result[:valid]
    assert_includes result[:errors], "Headers text cannot be empty"
  end

  test "CORS headers are case-insensitive" do
    result = Everyday::CorsCheckerCalculator.new(
      headers_text: "access-control-allow-origin: https://example.com"
    ).call

    assert result[:valid]
    assert result[:cors_enabled]
    assert_equal "https://example.com", result[:cors_headers]["access-control-allow-origin"]
  end
end
