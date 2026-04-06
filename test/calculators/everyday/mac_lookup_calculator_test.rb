require "test_helper"

class Everyday::MacLookupCalculatorTest < ActiveSupport::TestCase
  test "looks up a known Apple MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "AC:DE:48:11:22:33").call

    assert result[:valid]
    assert_equal "AC:DE:48:11:22:33", result[:mac]
    assert_equal "AC:DE:48", result[:oui_prefix]
    assert_equal "Apple", result[:manufacturer]
    assert result[:is_unicast]
    assert_not result[:is_multicast]
    assert result[:is_global]
    assert_not result[:is_local]
  end

  test "looks up a known VMware MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "00:50:56:AA:BB:CC").call

    assert result[:valid]
    assert_equal "VMware", result[:manufacturer]
  end

  test "looks up a known Cisco MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "00:00:0C:12:34:56").call

    assert result[:valid]
    assert_equal "Cisco", result[:manufacturer]
  end

  test "returns Unknown for unrecognized OUI" do
    result = Everyday::MacLookupCalculator.new(mac_address: "AA:AA:AA:11:22:33").call

    assert result[:valid]
    assert_equal "Unknown", result[:manufacturer]
  end

  test "normalizes MAC with hyphens" do
    result = Everyday::MacLookupCalculator.new(mac_address: "AC-DE-48-11-22-33").call

    assert result[:valid]
    assert_equal "AC:DE:48:11:22:33", result[:mac]
    assert_equal "Apple", result[:manufacturer]
  end

  test "normalizes MAC without separators" do
    result = Everyday::MacLookupCalculator.new(mac_address: "ACDE48112233").call

    assert result[:valid]
    assert_equal "AC:DE:48:11:22:33", result[:mac]
    assert_equal "Apple", result[:manufacturer]
  end

  test "normalizes lowercase input to uppercase" do
    result = Everyday::MacLookupCalculator.new(mac_address: "ac:de:48:11:22:33").call

    assert result[:valid]
    assert_equal "AC:DE:48:11:22:33", result[:mac]
    assert_equal "Apple", result[:manufacturer]
  end

  test "detects multicast MAC address" do
    # First byte 01 has bit 0 = 1 (multicast)
    result = Everyday::MacLookupCalculator.new(mac_address: "01:00:5E:00:00:01").call

    assert result[:valid]
    assert result[:is_multicast]
    assert_not result[:is_unicast]
  end

  test "detects locally administered MAC address" do
    # First byte 02 has bit 1 = 1 (locally administered)
    result = Everyday::MacLookupCalculator.new(mac_address: "02:42:AC:11:00:02").call

    assert result[:valid]
    assert result[:is_local]
    assert_not result[:is_global]
    assert_equal "Docker", result[:manufacturer]
  end

  test "detects Docker container MAC" do
    result = Everyday::MacLookupCalculator.new(mac_address: "02:42:AC:11:00:02").call

    assert result[:valid]
    assert_equal "Docker", result[:manufacturer]
    assert result[:is_local]
  end

  test "detects QEMU/KVM MAC" do
    result = Everyday::MacLookupCalculator.new(mac_address: "52:54:00:AB:CD:EF").call

    assert result[:valid]
    assert_equal "QEMU/KVM", result[:manufacturer]
  end

  test "detects Raspberry Pi MAC" do
    result = Everyday::MacLookupCalculator.new(mac_address: "DC:A6:32:01:02:03").call

    assert result[:valid]
    assert_equal "Raspberry Pi", result[:manufacturer]
  end

  test "returns error for empty MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "").call

    assert_not result[:valid]
    assert_includes result[:errors], "MAC address cannot be empty"
  end

  test "returns error for too short MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "AA:BB:CC").call

    assert_not result[:valid]
    assert_includes result[:errors], "MAC address must be 6 hex pairs (e.g. AA:BB:CC:DD:EE:FF)"
  end

  test "returns error for MAC with invalid hex characters" do
    result = Everyday::MacLookupCalculator.new(mac_address: "GG:HH:II:JJ:KK:LL").call

    assert_not result[:valid]
    assert_includes result[:errors], "MAC address must be 6 hex pairs (e.g. AA:BB:CC:DD:EE:FF)"
  end

  test "returns error for too long MAC address" do
    result = Everyday::MacLookupCalculator.new(mac_address: "AA:BB:CC:DD:EE:FF:00").call

    assert_not result[:valid]
    assert_includes result[:errors], "MAC address must be 6 hex pairs (e.g. AA:BB:CC:DD:EE:FF)"
  end

  test "strips whitespace from input" do
    result = Everyday::MacLookupCalculator.new(mac_address: "  AC:DE:48:11:22:33  ").call

    assert result[:valid]
    assert_equal "AC:DE:48:11:22:33", result[:mac]
  end
end
