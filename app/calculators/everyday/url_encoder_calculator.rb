# frozen_string_literal: true

require "cgi"
require "uri"

module Everyday
  class UrlEncoderCalculator
    attr_reader :errors

    SUPPORTED_ACTIONS = %w[encode decode].freeze

    def initialize(text:, action: "encode")
      @text = text.to_s
      @action = action.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @action == "encode"
        encode_text
      else
        decode_text
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Action must be encode or decode" unless SUPPORTED_ACTIONS.include?(@action)
    end

    def encode_text
      component_encoded = CGI.escape(@text)
      full_encoded = URI::DEFAULT_PARSER.escape(@text)

      {
        valid: true,
        action: "encode",
        component_encoded: component_encoded,
        full_encoded: full_encoded,
        input_length: @text.length,
        output_length: component_encoded.length,
        input_bytes: @text.bytesize,
        output_bytes: component_encoded.bytesize
      }
    end

    def decode_text
      decoded = CGI.unescape(@text)

      {
        valid: true,
        action: "decode",
        decoded: decoded,
        input_length: @text.length,
        output_length: decoded.length,
        input_bytes: @text.bytesize,
        output_bytes: decoded.bytesize
      }
    rescue ArgumentError => e
      @errors << "Invalid URL-encoded input: #{e.message}"
      { valid: false, errors: @errors }
    end
  end
end
