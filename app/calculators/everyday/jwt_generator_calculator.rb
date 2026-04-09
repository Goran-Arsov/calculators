# frozen_string_literal: true

require "base64"
require "json"
require "openssl"

module Everyday
  class JwtGeneratorCalculator
    attr_reader :errors

    def initialize(header_json: '{"alg":"HS256","typ":"JWT"}', payload_json:, secret_key:)
      @header_json = header_json.to_s.strip
      @payload_json = payload_json.to_s.strip
      @secret_key = secret_key.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      header = parse_json(@header_json, "header")
      payload = parse_json(@payload_json, "payload")
      return { valid: false, errors: @errors } if @errors.any?

      header_b64 = base64url_encode(@header_json)
      payload_b64 = base64url_encode(@payload_json)

      signing_input = "#{header_b64}.#{payload_b64}"
      signature = OpenSSL::HMAC.digest("SHA256", @secret_key, signing_input)
      signature_b64 = base64url_encode_raw(signature)

      jwt_token = "#{header_b64}.#{payload_b64}.#{signature_b64}"

      {
        valid: true,
        jwt_token: jwt_token,
        decoded_header: header,
        decoded_payload: payload,
        is_valid: true,
        header_b64: header_b64,
        payload_b64: payload_b64,
        signature_b64: signature_b64
      }
    end

    private

    def validate!
      @errors << "Payload JSON cannot be empty" if @payload_json.empty?
      @errors << "Header JSON cannot be empty" if @header_json.empty?
      @errors << "Secret key cannot be empty" if @secret_key.empty?
    end

    def parse_json(str, name)
      JSON.parse(str)
    rescue JSON::ParserError => e
      @errors << "Invalid JSON in #{name}: #{e.message}"
      nil
    end

    def base64url_encode(str)
      Base64.urlsafe_encode64(str, padding: false)
    end

    def base64url_encode_raw(bytes)
      Base64.urlsafe_encode64(bytes, padding: false)
    end
  end
end
