require "test_helper"

class Everyday::HtaccessGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates force HTTPS rule" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "force_https" => true }).call
    assert result[:valid]
    assert_includes result[:output], "RewriteCond %{HTTPS} off"
    assert_includes result[:output], "R=301"
  end

  test "generates www redirect rule" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "www_redirect" => true }).call
    assert result[:valid]
    assert_includes result[:output], "!^www"
  end

  test "generates non-www redirect rule" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "non_www_redirect" => true }).call
    assert result[:valid]
    assert_includes result[:output], "^www"
  end

  test "generates gzip compression" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "gzip" => true }).call
    assert result[:valid]
    assert_includes result[:output], "mod_deflate"
    assert_includes result[:output], "DEFLATE"
  end

  test "generates browser caching" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "caching" => true }).call
    assert result[:valid]
    assert_includes result[:output], "mod_expires"
    assert_includes result[:output], "ExpiresActive On"
  end

  test "generates security headers" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "security_headers" => true }).call
    assert result[:valid]
    assert_includes result[:output], "X-Content-Type-Options"
    assert_includes result[:output], "X-Frame-Options"
  end

  test "generates custom error pages" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "error_pages" => true }).call
    assert result[:valid]
    assert_includes result[:output], "ErrorDocument 404"
  end

  test "generates directory listing protection" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "disable_directory_listing" => true }).call
    assert result[:valid]
    assert_includes result[:output], "Options -Indexes"
  end

  test "generates file protection" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "protect_sensitive_files" => true }).call
    assert result[:valid]
    assert_includes result[:output], "env"
    assert_includes result[:output], "htpasswd"
  end

  test "combines multiple options" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "force_https" => true, "gzip" => true, "caching" => true }).call
    assert result[:valid]
    assert_equal 3, result[:section_count]
  end

  test "returns empty output when no options selected" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: {}).call
    assert result[:valid]
    assert_equal 0, result[:section_count]
  end

  test "generates hotlink protection with custom domain" do
    result = Everyday::HtaccessGeneratorCalculator.new(options: { "hotlink_protection" => true, "domain" => "mysite.com" }).call
    assert result[:valid]
    assert_includes result[:output], "mysite\\.com"
  end
end
