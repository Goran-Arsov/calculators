# frozen_string_literal: true

require "ipaddr"

module Everyday
  class SubnetCalculator
    attr_reader :errors

    def initialize(ip_address:, prefix_length:)
      @ip_address = ip_address.to_s.strip
      @prefix_length = prefix_length.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      network = IPAddr.new("#{@ip_address}/#{@prefix_length}")
      subnet_mask_str = network.netmask
      wildcard_mask = wildcard_from_mask(subnet_mask_str)
      broadcast = broadcast_address(network)
      total_hosts = 2**(32 - @prefix_length)
      usable_hosts = @prefix_length >= 31 ? total_hosts : [ total_hosts - 2, 0 ].max

      {
        valid: true,
        ip_address: @ip_address,
        prefix_length: @prefix_length,
        network_address: network.to_s,
        broadcast_address: broadcast.to_s,
        subnet_mask: subnet_mask_str,
        wildcard_mask: wildcard_mask,
        first_usable_host: first_usable(network),
        last_usable_host: last_usable(broadcast),
        total_hosts: total_hosts,
        usable_hosts: usable_hosts,
        cidr_notation: "#{network.to_s}/#{@prefix_length}",
        ip_class: ip_class(@ip_address),
        is_private: private_ip?(@ip_address),
        binary_mask: to_binary_mask(@prefix_length)
      }
    rescue IPAddr::InvalidAddressError => e
      @errors << "Invalid IP address: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "IP address cannot be empty" if @ip_address.empty?
      @errors << "Prefix length must be between 0 and 32" unless (0..32).cover?(@prefix_length)

      unless @ip_address.empty?
        octets = @ip_address.split(".")
        unless octets.length == 4 && octets.all? { |o| o.match?(/\A\d{1,3}\z/) && o.to_i.between?(0, 255) }
          @errors << "IP address must be a valid IPv4 address (e.g. 192.168.1.0)"
        end
      end
    end

    def broadcast_address(network)
      mask_int = (0xFFFFFFFF << (32 - @prefix_length)) & 0xFFFFFFFF
      network_int = ip_to_int(network.to_s)
      broadcast_int = network_int | (~mask_int & 0xFFFFFFFF)
      int_to_ip(broadcast_int)
    end

    def first_usable(network)
      return network.to_s if @prefix_length >= 31

      int_to_ip(ip_to_int(network.to_s) + 1)
    end

    def last_usable(broadcast)
      return broadcast.to_s if @prefix_length >= 31

      int_to_ip(ip_to_int(broadcast.to_s) - 1)
    end

    def wildcard_from_mask(mask_str)
      octets = mask_str.split(".").map { |o| 255 - o.to_i }
      octets.join(".")
    end

    def ip_class(ip)
      first_octet = ip.split(".").first.to_i
      case first_octet
      when 0..127 then "A"
      when 128..191 then "B"
      when 192..223 then "C"
      when 224..239 then "D (Multicast)"
      when 240..255 then "E (Reserved)"
      end
    end

    def private_ip?(ip)
      addr = IPAddr.new(ip)
      [
        IPAddr.new("10.0.0.0/8"),
        IPAddr.new("172.16.0.0/12"),
        IPAddr.new("192.168.0.0/16")
      ].any? { |range| range.include?(addr) }
    rescue IPAddr::InvalidAddressError
      false
    end

    def to_binary_mask(prefix)
      mask = ("1" * prefix).ljust(32, "0")
      mask.scan(/.{8}/).join(".")
    end

    def ip_to_int(ip)
      octets = ip.to_s.split(".")
      (octets[0].to_i << 24) | (octets[1].to_i << 16) | (octets[2].to_i << 8) | octets[3].to_i
    end

    def int_to_ip(int)
      [
        (int >> 24) & 0xFF,
        (int >> 16) & 0xFF,
        (int >> 8) & 0xFF,
        int & 0xFF
      ].join(".")
    end
  end
end
