# frozen_string_literal: true

require "base64"
require "json"

module Everyday
  class JwtDecoderCalculator
    attr_reader :errors

    def initialize(token:)
      @token = token.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parts = @token.split(".")
      unless parts.length == 3
        @errors << "Invalid JWT format: expected 3 parts separated by dots, got #{parts.length}"
        return { valid: false, errors: @errors }
      end

      header = decode_segment(parts[0], "header")
      payload = decode_segment(parts[1], "payload")
      return { valid: false, errors: @errors } if @errors.any?

      signature_b64 = parts[2]

      exp = payload["exp"]
      iat = payload["iat"]
      nbf = payload["nbf"]

      now = Time.now.to_i

      {
        valid: true,
        header: header,
        payload: payload,
        signature: signature_b64,
        algorithm: header["alg"],
        token_type: header["typ"],
        expires_at: exp ? Time.at(exp).utc.iso8601 : nil,
        issued_at: iat ? Time.at(iat).utc.iso8601 : nil,
        not_before: nbf ? Time.at(nbf).utc.iso8601 : nil,
        is_expired: exp ? (now > exp) : nil,
        expires_in_seconds: exp ? (exp - now) : nil,
        issuer: payload["iss"],
        subject: payload["sub"],
        audience: payload["aud"],
        claim_count: payload.keys.length
      }
    end

    private

    def validate!
      @errors << "Token cannot be empty" if @token.empty?
    end

    def decode_segment(segment, name)
      # Add padding if necessary
      padded = segment + "=" * ((4 - segment.length % 4) % 4)
      decoded = Base64.urlsafe_decode64(padded)
      JSON.parse(decoded)
    rescue ArgumentError
      @errors << "Invalid Base64 encoding in #{name}"
      nil
    rescue JSON::ParserError
      @errors << "Invalid JSON in #{name}"
      nil
    end
  end
end
