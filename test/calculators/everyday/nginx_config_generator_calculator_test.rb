require "test_helper"

class Everyday::NginxConfigGeneratorCalculatorTest < ActiveSupport::TestCase
  test "generates basic config with server name and defaults" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "example.com").call
    assert_equal true, result[:valid]
    assert_includes result[:config], "server_name example.com"
    assert_includes result[:config], "listen 80"
    assert_includes result[:config], "root /var/www/html"
    assert_includes result[:config], "try_files"
    assert result[:line_count] > 0
  end

  test "generates SSL config" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      listen_port: 443,
      ssl: true,
      ssl_certificate: "/etc/ssl/certs/example.crt",
      ssl_certificate_key: "/etc/ssl/private/example.key"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "ssl_certificate /etc/ssl/certs/example.crt"
    assert_includes result[:config], "ssl_certificate_key /etc/ssl/private/example.key"
    assert_includes result[:config], "ssl_protocols"
    assert_equal true, result[:ssl]
  end

  test "generates reverse proxy config" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      proxy_pass: "http://127.0.0.1:3000"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "proxy_pass http://127.0.0.1:3000"
    assert_includes result[:config], "proxy_set_header Host $host"
    assert_equal true, result[:has_proxy]
  end

  test "generates gzip config" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "example.com", gzip: true).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "gzip on"
    assert_includes result[:config], "gzip_vary on"
    assert_includes result[:config], "gzip_types"
    assert_equal true, result[:gzip]
  end

  test "generates static asset caching config" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "example.com", cache_static: true).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "expires 30d"
    assert_includes result[:config], "Cache-Control"
    assert_equal true, result[:cache_static]
  end

  test "generates HTTP to HTTPS redirect" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      listen_port: 443,
      ssl: true,
      redirect_http: true
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "return 301 https://$host$request_uri"
    assert_equal true, result[:redirect_http]
  end

  test "generates full config with all options" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      listen_port: 443,
      ssl: true,
      gzip: true,
      cache_static: true,
      redirect_http: true,
      proxy_pass: "http://127.0.0.1:3000"
    ).call
    assert_equal true, result[:valid]
    assert_includes result[:config], "ssl_certificate"
    assert_includes result[:config], "gzip on"
    assert_includes result[:config], "expires 30d"
    assert_includes result[:config], "proxy_pass"
    assert_includes result[:config], "return 301"
  end

  test "accepts wildcard server name" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "*.example.com").call
    assert_equal true, result[:valid]
    assert_includes result[:config], "server_name *.example.com"
  end

  # --- Validation errors ---

  test "error when server name is blank" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "").call
    assert_equal false, result[:valid]
    assert_includes result[:errors], "Server name is required"
  end

  test "error when server name has invalid characters" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "exam ple.com").call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("invalid characters") }
  end

  test "error when port out of range" do
    result = Everyday::NginxConfigGeneratorCalculator.new(server_name: "example.com", listen_port: 99_999).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("port") }
  end

  test "error when SSL enabled without certificate path" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      ssl: true,
      ssl_certificate: "",
      ssl_certificate_key: ""
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("SSL certificate path") }
  end

  test "error when proxy pass URL is invalid" do
    result = Everyday::NginxConfigGeneratorCalculator.new(
      server_name: "example.com",
      proxy_pass: "ftp://invalid"
    ).call
    assert_equal false, result[:valid]
    assert result[:errors].any? { |e| e.include?("Proxy pass") }
  end

  test "errors accessor returns empty array before call" do
    calc = Everyday::NginxConfigGeneratorCalculator.new(server_name: "example.com")
    assert_equal [], calc.errors
  end
end
