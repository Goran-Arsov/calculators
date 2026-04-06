# frozen_string_literal: true

require "digest"

module Everyday
  class HashGeneratorCalculator
    attr_reader :errors

    SUPPORTED_ALGORITHMS = %w[sha256 sha384 sha512 md5].freeze

    def initialize(text:, algorithm: "sha256")
      @text = text.to_s
      @algorithm = algorithm.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      digest = compute_digest

      {
        valid: true,
        hash: digest,
        algorithm: @algorithm,
        input_length: @text.length,
        hash_length: digest.length
      }
    end

    private

    def compute_digest
      case @algorithm
      when "sha256"
        Digest::SHA256.hexdigest(@text)
      when "sha384"
        Digest::SHA384.hexdigest(@text)
      when "sha512"
        Digest::SHA512.hexdigest(@text)
      when "md5"
        Digest::MD5.hexdigest(@text)
      end
    end

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Unsupported algorithm: #{@algorithm}. Supported: #{SUPPORTED_ALGORITHMS.join(', ')}" unless SUPPORTED_ALGORITHMS.include?(@algorithm)
    end
  end
end
