require "test_helper"

class Everyday::CurlToCodeCalculatorTest < ActiveSupport::TestCase
  test "parses simple GET request" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://api.example.com/users").call
    assert result[:valid]
    assert_equal "GET", result[:method]
    assert_equal "https://api.example.com/users", result[:url]
  end

  test "parses POST with data" do
    result = Everyday::CurlToCodeCalculator.new(curl: 'curl -X POST -d \'{"name":"John"}\' https://api.example.com/users').call
    assert result[:valid]
    assert_equal "POST", result[:method]
    assert result[:has_body]
  end

  test "parses headers" do
    result = Everyday::CurlToCodeCalculator.new(curl: 'curl -H "Content-Type: application/json" -H "Authorization: Bearer token" https://api.example.com').call
    assert result[:valid]
    assert_equal 2, result[:header_count]
  end

  test "generates Python code" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://api.example.com", language: "python").call
    assert result[:valid]
    assert_includes result[:code], "import requests"
    assert_includes result[:code], "requests.get"
  end

  test "generates JavaScript code" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://api.example.com", language: "javascript").call
    assert result[:valid]
    assert_includes result[:code], "fetch"
  end

  test "generates Ruby code" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://api.example.com", language: "ruby").call
    assert result[:valid]
    assert_includes result[:code], "Net::HTTP"
  end

  test "generates PHP code" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://api.example.com", language: "php").call
    assert result[:valid]
    assert_includes result[:code], "curl_init"
  end

  test "auto-detects POST from -d flag" do
    result = Everyday::CurlToCodeCalculator.new(curl: 'curl -d "data" https://example.com').call
    assert result[:valid]
    assert_equal "POST", result[:method]
  end

  test "returns error for empty curl" do
    result = Everyday::CurlToCodeCalculator.new(curl: "").call
    assert_not result[:valid]
    assert_includes result[:errors], "cURL command cannot be empty"
  end

  test "returns error for unsupported language" do
    result = Everyday::CurlToCodeCalculator.new(curl: "curl https://example.com", language: "go").call
    assert_not result[:valid]
    assert result[:errors].any? { |e| e.include?("Unsupported language") }
  end
end
