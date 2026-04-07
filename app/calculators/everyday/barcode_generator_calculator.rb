# frozen_string_literal: true

module Everyday
  class BarcodeGeneratorCalculator
    attr_reader :errors

    SUPPORTED_FORMATS = %w[code128 ean13 code39].freeze

    CODE39_CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%"

    MAX_LENGTH = 500

    def initialize(text:, format: "code128")
      @text = text.to_s
      @format = format.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        text: @text,
        format: @format,
        character_count: @text.length
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Text exceeds maximum length of #{MAX_LENGTH} characters" if @text.length > MAX_LENGTH

      unless SUPPORTED_FORMATS.include?(@format)
        @errors << "Unsupported format: #{@format}. Supported formats: #{SUPPORTED_FORMATS.join(', ')}"
        return
      end

      case @format
      when "ean13"
        validate_ean13!
      when "code39"
        validate_code39!
      when "code128"
        validate_code128!
      end
    end

    def validate_ean13!
      unless @text.match?(/\A\d{12,13}\z/)
        @errors << "EAN-13 requires exactly 12 or 13 digits"
      end
    end

    def validate_code39!
      invalid = @text.chars.reject { |c| CODE39_CHARS.include?(c) }
      if invalid.any?
        @errors << "Code 39 does not support characters: #{invalid.uniq.join(', ')}"
      end
    end

    def validate_code128!
      invalid = @text.chars.reject { |c| c.ord >= 32 && c.ord <= 127 }
      if invalid.any?
        @errors << "Code 128 only supports ASCII characters 32-127"
      end
    end
  end
end
