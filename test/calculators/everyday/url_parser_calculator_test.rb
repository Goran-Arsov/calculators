require "test_helper"

class Everyday::UrlParserCalculatorTest < ActiveSupport::TestCase
  test "parses a full URL with all components" do
    result = Everyday::UrlParserCalculator.new(
      url: "https://user:pass@example.com:8080/path/to/page?key=value&foo=bar#section"
    ).call

    assert result[:valid]
    assert_equal "https", result[:scheme]
    assert_equal "user:pass", result[:userinfo]
    assert_equal "example.com", result[:host]
    assert_equal 8080, result[:port]
    assert_equal "/path/to/page", result[:path]
    assert_equal "key=value&foo=bar", result[:query]
    assert_equal "section", result[:fragment]
    assert_equal "value", result[:query_params]["key"]
    assert_equal "bar", result[:query_params]["foo"]
    assert_equal 2, result[:query_param_count]
  end

  test "parses a simple URL with defaults" do
    result = Everyday::UrlParserCalculator.new(url: "https://example.com").call

    assert result[:valid]
    assert_equal "https", result[:scheme]
    assert_equal "example.com", result[:host]
    assert_equal 443, result[:port]
    assert result[:port_is_default]
    assert_equal "/", result[:path]
    assert_nil result[:query]
    assert_nil result[:fragment]
    assert_equal({}, result[:query_params])
  end

  test "parses URL with query parameters" do
    result = Everyday::UrlParserCalculator.new(
      url: "https://search.example.com/results?q=ruby+on+rails&page=2&lang=en"
    ).call

    assert result[:valid]
    assert_equal "ruby on rails", result[:query_params]["q"]
    assert_equal "2", result[:query_params]["page"]
    assert_equal "en", result[:query_params]["lang"]
    assert_equal 3, result[:query_param_count]
  end

  test "identifies non-default port" do
    result = Everyday::UrlParserCalculator.new(url: "https://example.com:9090/api").call

    assert result[:valid]
    assert_equal 9090, result[:port]
    assert_not result[:port_is_default]
  end

  test "parses HTTP URL with default port" do
    result = Everyday::UrlParserCalculator.new(url: "http://example.com/page").call

    assert result[:valid]
    assert_equal "http", result[:scheme]
    assert_equal 80, result[:port]
    assert result[:port_is_default]
  end

  test "parses FTP URL" do
    result = Everyday::UrlParserCalculator.new(url: "ftp://files.example.com/data.csv").call

    assert result[:valid]
    assert_equal "ftp", result[:scheme]
    assert_equal 21, result[:default_port]
  end

  test "parses URL with fragment only" do
    result = Everyday::UrlParserCalculator.new(url: "https://example.com/docs#getting-started").call

    assert result[:valid]
    assert_equal "getting-started", result[:fragment]
    assert_nil result[:query]
  end

  test "returns error for empty URL" do
    result = Everyday::UrlParserCalculator.new(url: "").call

    assert_not result[:valid]
    assert_includes result[:errors], "URL cannot be empty"
  end

  test "returns error for whitespace-only URL" do
    result = Everyday::UrlParserCalculator.new(url: "   ").call

    assert_not result[:valid]
    assert_includes result[:errors], "URL cannot be empty"
  end

  test "handles URL with empty query string" do
    result = Everyday::UrlParserCalculator.new(url: "https://example.com/page?").call

    assert result[:valid]
    assert_equal 0, result[:query_param_count]
  end

  test "handles URL with encoded characters in query" do
    result = Everyday::UrlParserCalculator.new(
      url: "https://example.com/search?q=hello%20world&lang=en"
    ).call

    assert result[:valid]
    assert_equal "hello world", result[:query_params]["q"]
  end

  test "parses userinfo without password" do
    result = Everyday::UrlParserCalculator.new(url: "https://admin@example.com/dashboard").call

    assert result[:valid]
    assert_equal "admin", result[:userinfo]
  end
end
