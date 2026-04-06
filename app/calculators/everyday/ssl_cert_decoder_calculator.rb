# frozen_string_literal: true

require "openssl"
require "digest"

module Everyday
  class SslCertDecoderCalculator
    attr_reader :errors

    EXPIRY_WARNING_DAYS = 30

    def initialize(pem_text:)
      @pem_text = pem_text.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      begin
        cert = OpenSSL::X509::Certificate.new(@pem_text)
      rescue OpenSSL::X509::CertificateError => e
        @errors << "Invalid certificate: #{e.message}"
        return { valid: false, errors: @errors }
      end

      now = Time.now
      days_until_expiry = ((cert.not_after - now) / 86_400).to_i
      is_expired = cert.not_after < now
      is_self_signed = cert.issuer.to_s == cert.subject.to_s

      {
        valid: true,
        subject: parse_name(cert.subject),
        issuer: parse_name(cert.issuer),
        serial_number: cert.serial.to_s(16).upcase,
        not_before: cert.not_before.utc.iso8601,
        not_after: cert.not_after.utc.iso8601,
        is_expired: is_expired,
        days_until_expiry: days_until_expiry,
        expiry_status: expiry_status(is_expired, days_until_expiry),
        signature_algorithm: cert.signature_algorithm,
        public_key_algorithm: public_key_algorithm(cert.public_key),
        public_key_size: public_key_size(cert.public_key),
        subject_alternative_names: extract_sans(cert),
        is_self_signed: is_self_signed,
        fingerprints: {
          sha1: Digest::SHA1.hexdigest(cert.to_der).scan(/../).join(":").upcase,
          sha256: Digest::SHA256.hexdigest(cert.to_der).scan(/../).join(":").upcase
        },
        version: cert.version + 1
      }
    end

    private

    def validate!
      @errors << "Certificate text cannot be empty" if @pem_text.strip.empty?
      unless @pem_text.include?("-----BEGIN CERTIFICATE-----")
        @errors << "Text does not appear to be a PEM-encoded certificate. It should start with -----BEGIN CERTIFICATE-----"
      end
    end

    def parse_name(name)
      result = {}
      name.to_a.each do |entry|
        key = entry[0]
        value = entry[1].to_s
        case key
        when "CN" then result[:common_name] = value
        when "O" then result[:organization] = value
        when "OU" then result[:organizational_unit] = value
        when "C" then result[:country] = value
        when "ST" then result[:state] = value
        when "L" then result[:locality] = value
        when "emailAddress" then result[:email] = value
        end
      end
      result[:full] = name.to_s
      result
    end

    def extract_sans(cert)
      san_extension = cert.extensions.find { |ext| ext.oid == "subjectAltName" }
      return [] unless san_extension

      san_extension.value.split(",").map do |entry|
        entry.strip.sub(/\ADNS:/, "").sub(/\AIP Address:/, "").sub(/\Aemail:/, "")
      end
    end

    def public_key_algorithm(key)
      case key
      when OpenSSL::PKey::RSA then "RSA"
      when OpenSSL::PKey::EC then "EC"
      when OpenSSL::PKey::DSA then "DSA"
      else key.class.name.split("::").last
      end
    end

    def public_key_size(key)
      case key
      when OpenSSL::PKey::RSA then key.n.num_bits
      when OpenSSL::PKey::EC then key.group.degree
      when OpenSSL::PKey::DSA then key.p.num_bits
      else 0
      end
    end

    def expiry_status(is_expired, days_until_expiry)
      if is_expired
        "expired"
      elsif days_until_expiry <= EXPIRY_WARNING_DAYS
        "expiring_soon"
      else
        "valid"
      end
    end
  end
end
