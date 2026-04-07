# frozen_string_literal: true

require "base64"

module Everyday
  class Base64EncoderCalculator
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
      standard = Base64.strict_encode64(@text)
      url_safe = Base64.urlsafe_encode64(@text)

      {
        valid: true,
        action: "encode",
        standard: standard,
        url_safe: url_safe,
        input_length: @text.length,
        output_length: standard.length,
        input_bytes: @text.bytesize,
        output_bytes: standard.bytesize
      }
    end

    def decode_text
      result = { valid: true, action: "decode" }

      begin
        decoded = Base64.strict_decode64(@text.strip)
        decoded.force_encoding("UTF-8")
        unless decoded.valid_encoding?
          decoded = decoded.encode("UTF-8", "ISO-8859-1", invalid: :replace, undef: :replace)
        end
        result[:decoded] = decoded
        result[:input_length] = @text.length
        result[:output_length] = decoded.length
        result[:input_bytes] = @text.bytesize
        result[:output_bytes] = decoded.bytesize
      rescue ArgumentError
        begin
          decoded = Base64.urlsafe_decode64(@text.strip)
          decoded.force_encoding("UTF-8")
          unless decoded.valid_encoding?
            decoded = decoded.encode("UTF-8", "ISO-8859-1", invalid: :replace, undef: :replace)
          end
          result[:decoded] = decoded
          result[:input_length] = @text.length
          result[:output_length] = decoded.length
          result[:input_bytes] = @text.bytesize
          result[:output_bytes] = decoded.bytesize
          result[:format] = "url_safe"
        rescue ArgumentError
          @errors << "Invalid Base64 input"
          return { valid: false, errors: @errors }
        end
      end

      result
    end
  end
end
