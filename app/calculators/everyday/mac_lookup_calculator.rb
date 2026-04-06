# frozen_string_literal: true

module Everyday
  class MacLookupCalculator
    attr_reader :errors

    OUI_DATABASE = {
      "00:00:0C" => "Cisco",
      "00:01:42" => "Cisco",
      "FC:FB:FB" => "Cisco",
      "00:1A:A0" => "Dell",
      "00:14:22" => "Dell",
      "00:50:56" => "VMware",
      "00:0C:29" => "VMware",
      "00:05:69" => "VMware",
      "FE:FF:FF" => "VMware (legacy)",
      "00:1C:42" => "Parallels",
      "08:00:27" => "Oracle VirtualBox",
      "00:03:FF" => "Microsoft Hyper-V",
      "00:15:5D" => "Microsoft Hyper-V",
      "AC:DE:48" => "Apple",
      "A4:83:E7" => "Apple",
      "F0:18:98" => "Apple",
      "3C:22:FB" => "Apple",
      "00:1B:63" => "Apple",
      "00:25:00" => "Apple",
      "00:26:BB" => "Apple",
      "68:5B:35" => "Apple",
      "A8:86:DD" => "Apple",
      "7C:D1:C3" => "Apple",
      "00:0D:93" => "Apple",
      "00:23:12" => "Apple",
      "00:25:BC" => "Apple",
      "DC:A6:32" => "Raspberry Pi",
      "B8:27:EB" => "Raspberry Pi",
      "E4:5F:01" => "Raspberry Pi",
      "00:1A:7D" => "Cyber-i Networks",
      "3C:D0:F8" => "Google",
      "F4:F5:E8" => "Google",
      "94:EB:2C" => "Google",
      "54:60:09" => "Google",
      "A4:77:33" => "Google",
      "B0:BE:76" => "TP-Link",
      "50:C7:BF" => "TP-Link",
      "EC:08:6B" => "TP-Link",
      "30:B5:C2" => "TP-Link",
      "14:CC:20" => "TP-Link",
      "00:1E:58" => "D-Link",
      "1C:7E:E5" => "D-Link",
      "28:10:7B" => "D-Link",
      "C0:A0:BB" => "D-Link",
      "E0:46:9A" => "Netgear",
      "A4:2B:8C" => "Netgear",
      "6C:B0:CE" => "Netgear",
      "30:46:9A" => "Netgear",
      "00:24:D7" => "Intel",
      "00:1B:21" => "Intel",
      "3C:97:0E" => "Intel",
      "68:05:CA" => "Intel",
      "A0:36:9F" => "Intel",
      "00:1A:2B" => "Hewlett-Packard",
      "3C:D9:2B" => "Hewlett-Packard",
      "00:21:5A" => "Hewlett-Packard",
      "00:50:B6" => "Belkin",
      "94:10:3E" => "Belkin",
      "E8:4E:06" => "Samsung",
      "8C:77:12" => "Samsung",
      "00:26:37" => "Samsung",
      "C4:73:1E" => "Samsung",
      "FC:F1:36" => "Samsung",
      "E8:6F:38" => "Xiaomi",
      "28:6C:07" => "Xiaomi",
      "64:B4:73" => "Xiaomi",
      "00:E0:4C" => "Realtek",
      "52:54:00" => "QEMU/KVM",
      "02:42:AC" => "Docker",
      "02:42:00" => "Docker",
      "00:16:3E" => "Xen"
    }.freeze

    def initialize(mac_address:)
      @raw_mac = mac_address.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      normalized = normalize_mac(@raw_mac)
      oui_prefix = normalized[0, 8] # "XX:XX:XX"
      first_byte = normalized[0, 2].to_i(16)

      {
        valid: true,
        mac: normalized,
        oui_prefix: oui_prefix,
        manufacturer: OUI_DATABASE.fetch(oui_prefix.upcase, "Unknown"),
        is_unicast: (first_byte & 0x01).zero?,
        is_multicast: (first_byte & 0x01) == 1,
        is_global: (first_byte & 0x02).zero?,
        is_local: (first_byte & 0x02) == 2
      }
    end

    private

    def validate!
      if @raw_mac.empty?
        @errors << "MAC address cannot be empty"
        return
      end

      hex = @raw_mac.gsub(/[:\-.]/, "")
      unless hex.match?(/\A[0-9a-fA-F]{12}\z/)
        @errors << "MAC address must be 6 hex pairs (e.g. AA:BB:CC:DD:EE:FF)"
      end
    end

    def normalize_mac(mac)
      hex = mac.gsub(/[:\-.]/, "").upcase
      hex.scan(/.{2}/).join(":")
    end
  end
end
