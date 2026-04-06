require "test_helper"

class Everyday::SubnetCalculatorTest < ActiveSupport::TestCase
  test "calculates /24 subnet correctly" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.0", prefix_length: 24).call

    assert result[:valid]
    assert_equal "192.168.1.0", result[:network_address]
    assert_equal "192.168.1.255", result[:broadcast_address]
    assert_equal "255.255.255.0", result[:subnet_mask]
    assert_equal "0.0.0.255", result[:wildcard_mask]
    assert_equal "192.168.1.1", result[:first_usable_host]
    assert_equal "192.168.1.254", result[:last_usable_host]
    assert_equal 256, result[:total_hosts]
    assert_equal 254, result[:usable_hosts]
    assert_equal "192.168.1.0/24", result[:cidr_notation]
  end

  test "calculates /16 subnet correctly" do
    result = Everyday::SubnetCalculator.new(ip_address: "172.16.0.0", prefix_length: 16).call

    assert result[:valid]
    assert_equal "172.16.0.0", result[:network_address]
    assert_equal "172.16.255.255", result[:broadcast_address]
    assert_equal "255.255.0.0", result[:subnet_mask]
    assert_equal "0.0.255.255", result[:wildcard_mask]
    assert_equal 65536, result[:total_hosts]
    assert_equal 65534, result[:usable_hosts]
  end

  test "calculates /32 host route" do
    result = Everyday::SubnetCalculator.new(ip_address: "10.0.0.1", prefix_length: 32).call

    assert result[:valid]
    assert_equal "10.0.0.1", result[:network_address]
    assert_equal "10.0.0.1", result[:broadcast_address]
    assert_equal "255.255.255.255", result[:subnet_mask]
    assert_equal "0.0.0.0", result[:wildcard_mask]
    assert_equal 1, result[:total_hosts]
    assert_equal 1, result[:usable_hosts]
  end

  test "calculates /31 point-to-point link" do
    result = Everyday::SubnetCalculator.new(ip_address: "10.0.0.0", prefix_length: 31).call

    assert result[:valid]
    assert_equal 2, result[:total_hosts]
    assert_equal 2, result[:usable_hosts]
    assert_equal "10.0.0.0", result[:first_usable_host]
    assert_equal "10.0.0.1", result[:last_usable_host]
  end

  test "calculates /8 subnet correctly" do
    result = Everyday::SubnetCalculator.new(ip_address: "10.0.0.0", prefix_length: 8).call

    assert result[:valid]
    assert_equal "10.0.0.0", result[:network_address]
    assert_equal "10.255.255.255", result[:broadcast_address]
    assert_equal "255.0.0.0", result[:subnet_mask]
    assert_equal 16777216, result[:total_hosts]
    assert_equal 16777214, result[:usable_hosts]
  end

  test "identifies IP class A" do
    result = Everyday::SubnetCalculator.new(ip_address: "10.0.0.1", prefix_length: 24).call
    assert_equal "A", result[:ip_class]
  end

  test "identifies IP class B" do
    result = Everyday::SubnetCalculator.new(ip_address: "172.16.0.1", prefix_length: 24).call
    assert_equal "B", result[:ip_class]
  end

  test "identifies IP class C" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.1", prefix_length: 24).call
    assert_equal "C", result[:ip_class]
  end

  test "identifies private IP in 10.x range" do
    result = Everyday::SubnetCalculator.new(ip_address: "10.20.30.40", prefix_length: 24).call
    assert result[:is_private]
  end

  test "identifies private IP in 172.16-31.x range" do
    result = Everyday::SubnetCalculator.new(ip_address: "172.20.0.1", prefix_length: 24).call
    assert result[:is_private]
  end

  test "identifies private IP in 192.168.x range" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.0.1", prefix_length: 24).call
    assert result[:is_private]
  end

  test "identifies public IP" do
    result = Everyday::SubnetCalculator.new(ip_address: "8.8.8.8", prefix_length: 24).call
    assert_not result[:is_private]
  end

  test "generates correct binary mask" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.0", prefix_length: 24).call
    assert_equal "11111111.11111111.11111111.00000000", result[:binary_mask]
  end

  test "generates binary mask for /20" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.0.0", prefix_length: 20).call
    assert_equal "11111111.11111111.11110000.00000000", result[:binary_mask]
  end

  test "normalizes IP to network address" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.100", prefix_length: 24).call

    assert result[:valid]
    assert_equal "192.168.1.0", result[:network_address]
    assert_equal "192.168.1.100", result[:ip_address]
  end

  test "returns error for empty IP address" do
    result = Everyday::SubnetCalculator.new(ip_address: "", prefix_length: 24).call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address cannot be empty"
  end

  test "returns error for invalid IP address" do
    result = Everyday::SubnetCalculator.new(ip_address: "999.999.999.999", prefix_length: 24).call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.0)"
  end

  test "returns error for prefix out of range" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.0", prefix_length: 33).call

    assert_not result[:valid]
    assert_includes result[:errors], "Prefix length must be between 0 and 32"
  end

  test "returns error for negative prefix" do
    result = Everyday::SubnetCalculator.new(ip_address: "192.168.1.0", prefix_length: -1).call

    assert_not result[:valid]
    assert_includes result[:errors], "Prefix length must be between 0 and 32"
  end

  test "returns error for non-numeric octets" do
    result = Everyday::SubnetCalculator.new(ip_address: "abc.def.ghi.jkl", prefix_length: 24).call

    assert_not result[:valid]
    assert_includes result[:errors], "IP address must be a valid IPv4 address (e.g. 192.168.1.0)"
  end
end
