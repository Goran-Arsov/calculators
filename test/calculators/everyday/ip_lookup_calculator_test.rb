require "test_helper"

class Everyday::IpLookupCalculatorTest < ActiveSupport::TestCase
  test "looks up a public Class A IP address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "8.8.8.8").call

    assert result[:valid]
    assert_equal "8.8.8.8", result[:ip]
    assert_equal 4, result[:ip_version]
    assert_equal "A", result[:ip_class]
    assert_not result[:is_private]
    assert_not result[:is_loopback]
    assert_equal "00001000.00001000.00001000.00001000", result[:binary_representation]
  end

  test "looks up a private 10.x IP address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "10.0.0.1").call

    assert result[:valid]
    assert_equal "A", result[:ip_class]
    assert result[:is_private]
    assert_not result[:is_loopback]
  end

  test "looks up a private 172.16.x IP address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "172.16.5.10").call

    assert result[:valid]
    assert_equal "B", result[:ip_class]
    assert result[:is_private]
  end

  test "looks up a private 192.168.x IP address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "192.168.1.1").call

    assert result[:valid]
    assert_equal "C", result[:ip_class]
    assert result[:is_private]
  end

  test "detects loopback address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "127.0.0.1").call

    assert result[:valid]
    assert_equal "A", result[:ip_class]
    assert result[:is_loopback]
  end

  test "identifies Class B address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "150.100.50.25").call

    assert result[:valid]
    assert_equal "B", result[:ip_class]
    assert_not result[:is_private]
  end

  test "identifies Class D multicast address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "224.0.0.1").call

    assert result[:valid]
    assert_equal "D (Multicast)", result[:ip_class]
  end

  test "identifies Class E reserved address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "240.0.0.1").call

    assert result[:valid]
    assert_equal "E (Reserved)", result[:ip_class]
  end

  test "generates correct binary representation" do
    result = Everyday::IpLookupCalculator.new(ip_address: "192.168.1.1").call

    assert_equal "11000000.10101000.00000001.00000001", result[:binary_representation]
  end

  test "generates binary for 0.0.0.0" do
    result = Everyday::IpLookupCalculator.new(ip_address: "0.0.0.0").call

    assert result[:valid]
    assert_equal "00000000.00000000.00000000.00000000", result[:binary_representation]
  end

  test "generates binary for 255.255.255.255" do
    result = Everyday::IpLookupCalculator.new(ip_address: "255.255.255.255").call

    assert result[:valid]
    assert_equal "11111111.11111111.11111111.11111111", result[:binary_representation]
  end

  test "172.32.x is not private" do
    result = Everyday::IpLookupCalculator.new(ip_address: "172.32.0.1").call

    assert result[:valid]
    assert_not result[:is_private]
  end

  test "returns error for empty IP address" do
    result = Everyday::IpLookupCalculator.new(ip_address: "").call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address cannot be empty"
  end

  test "returns error for invalid IP with too many octets" do
    result = Everyday::IpLookupCalculator.new(ip_address: "1.2.3.4.5").call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.1)"
  end

  test "returns error for IP with octet out of range" do
    result = Everyday::IpLookupCalculator.new(ip_address: "256.1.1.1").call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.1)"
  end

  test "returns error for non-numeric IP" do
    result = Everyday::IpLookupCalculator.new(ip_address: "abc.def.ghi.jkl").call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.1)"
  end

  test "returns error for IP with too few octets" do
    result = Everyday::IpLookupCalculator.new(ip_address: "192.168.1").call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.1)"
  end

  test "strips whitespace from input" do
    result = Everyday::IpLookupCalculator.new(ip_address: "  8.8.8.8  ").call

    assert result[:valid]
    assert_equal "8.8.8.8", result[:ip]
  end
end
