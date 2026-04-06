require "test_helper"

class Everyday::DnsLookupCalculatorTest < ActiveSupport::TestCase
  test "validates a standard domain" do
    result = Everyday::DnsLookupCalculator.new(domain: "example.com").call

    assert result[:valid]
    assert_equal "example.com", result[:domain]
    assert result[:is_valid_format]
  end

  test "validates a subdomain" do
    result = Everyday::DnsLookupCalculator.new(domain: "www.example.com").call

    assert result[:valid]
    assert_equal "www.example.com", result[:domain]
  end

  test "validates a multi-level subdomain" do
    result = Everyday::DnsLookupCalculator.new(domain: "mail.sub.example.co.uk").call

    assert result[:valid]
    assert_equal "mail.sub.example.co.uk", result[:domain]
  end

  test "normalizes domain to lowercase" do
    result = Everyday::DnsLookupCalculator.new(domain: "Example.COM").call

    assert result[:valid]
    assert_equal "example.com", result[:domain]
  end

  test "strips whitespace from input" do
    result = Everyday::DnsLookupCalculator.new(domain: "  example.com  ").call

    assert result[:valid]
    assert_equal "example.com", result[:domain]
  end

  test "validates domain with hyphens" do
    result = Everyday::DnsLookupCalculator.new(domain: "my-site.example.com").call

    assert result[:valid]
    assert_equal "my-site.example.com", result[:domain]
  end

  test "returns error for empty domain" do
    result = Everyday::DnsLookupCalculator.new(domain: "").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain name cannot be empty"
  end

  test "returns error for whitespace-only domain" do
    result = Everyday::DnsLookupCalculator.new(domain: "   ").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain name cannot be empty"
  end

  test "returns error for domain without TLD" do
    result = Everyday::DnsLookupCalculator.new(domain: "localhost").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain must be a valid format (e.g. example.com)"
  end

  test "returns error for domain with spaces" do
    result = Everyday::DnsLookupCalculator.new(domain: "example .com").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain must be a valid format (e.g. example.com)"
  end

  test "returns error for IP address as domain" do
    result = Everyday::DnsLookupCalculator.new(domain: "192.168.1.1").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain must be a valid format (e.g. example.com)"
  end

  test "returns error for domain starting with hyphen" do
    result = Everyday::DnsLookupCalculator.new(domain: "-example.com").call

    assert_not result[:valid]
    assert_includes result[:errors], "Domain must be a valid format (e.g. example.com)"
  end
end
