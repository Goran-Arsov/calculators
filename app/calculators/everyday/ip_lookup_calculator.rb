# frozen_string_literal: true

module Everyday
  class IpLookupCalculator
    attr_reader :errors

    def initialize(ip_address:)
      @ip_address = ip_address.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      octets = @ip_address.split(".").map(&:to_i)
      first_octet = octets[0]

      {
        valid: true,
        ip: @ip_address,
        ip_version: 4,
        ip_class: ip_class(first_octet),
        is_private: private_ip?(octets),
        is_loopback: loopback_ip?(octets),
        binary_representation: to_binary(octets)
      }
    end

    private

    def validate!
      if @ip_address.empty?
        @errors << "IP address cannot be empty"
        return
      end

      octets = @ip_address.split(".")
      unless octets.length == 4 && octets.all? { |o| o.match?(/\A\d{1,3}\z/) && o.to_i.between?(0, 255) }
        @errors << "IP address must be a valid IPv4 address (e.g. 192.168.1.1)"
      end
    end

    def ip_class(first_octet)
      case first_octet
      when 0..127 then "A"
      when 128..191 then "B"
      when 192..223 then "C"
      when 224..239 then "D (Multicast)"
      when 240..255 then "E (Reserved)"
      end
    end

    def private_ip?(octets)
      return true if octets[0] == 10
      return true if octets[0] == 172 && octets[1].between?(16, 31)
      return true if octets[0] == 192 && octets[1] == 168
      false
    end

    def loopback_ip?(octets)
      octets[0] == 127
    end

    def to_binary(octets)
      octets.map { |o| o.to_s(2).rjust(8, "0") }.join(".")
    end
  end
end
