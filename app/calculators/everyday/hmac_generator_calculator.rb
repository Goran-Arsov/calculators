# frozen_string_literal: true

require "openssl"

module Everyday
  class HmacGeneratorCalculator
    attr_reader :errors

    SUPPORTED_ALGORITHMS = %w[sha256 sha384 sha512].freeze

    def initialize(message:, secret_key:, algorithm: "sha256")
      @message = message.to_s
      @secret_key = secret_key.to_s
      @algorithm = algorithm.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      hmac_hex = compute_hmac

      {
        valid: true,
        hmac: hmac_hex,
        algorithm: @algorithm,
        message_length: @message.length,
        key_length: @secret_key.length,
        hmac_length: hmac_hex.length
      }
    end

    private

    def compute_hmac
      digest = OpenSSL::Digest.new(@algorithm)
      OpenSSL::HMAC.hexdigest(digest, @secret_key, @message)
    end

    def validate!
      @errors << "Message cannot be empty" if @message.strip.empty?
      @errors << "Secret key cannot be empty" if @secret_key.strip.empty?
      @errors << "Unsupported algorithm: #{@algorithm}. Supported: #{SUPPORTED_ALGORITHMS.join(', ')}" unless SUPPORTED_ALGORITHMS.include?(@algorithm)
    end
  end
end
