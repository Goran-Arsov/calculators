# frozen_string_literal: true

require "base64"
require "cgi"

module Everyday
  class StringEncoderCalculator
    attr_reader :errors

    def initialize(text:, operation: "encode")
      @text = text.to_s
      @operation = operation.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @operation == "encode"
        encode_all
      else
        decode_all
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Operation must be encode or decode" unless %w[encode decode].include?(@operation)
    end

    def encode_all
      {
        valid: true,
        operation: "encode",
        base64: Base64.strict_encode64(@text),
        url_encoded: CGI.escape(@text),
        html_entities: CGI.escapeHTML(@text)
      }
    end

    def decode_all
      results = { valid: true, operation: "decode" }

      begin
        results[:base64] = Base64.strict_decode64(@text)
      rescue ArgumentError
        results[:base64] = nil
        results[:base64_error] = "Invalid Base64 input"
      end

      begin
        results[:url_decoded] = CGI.unescape(@text)
      rescue StandardError
        results[:url_decoded] = nil
        results[:url_decoded_error] = "Invalid URL-encoded input"
      end

      results[:html_entities] = CGI.unescapeHTML(@text)
      results
    end
  end
end
