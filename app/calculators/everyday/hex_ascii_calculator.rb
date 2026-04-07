# frozen_string_literal: true

module Everyday
  class HexAsciiCalculator
    attr_reader :errors

    SUPPORTED_ACTIONS = %w[text_to_hex hex_to_text].freeze

    def initialize(text:, action: "text_to_hex")
      @text = text.to_s
      @action = action.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @action == "text_to_hex"
        text_to_hex
      else
        hex_to_text
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Action must be text_to_hex or hex_to_text" unless SUPPORTED_ACTIONS.include?(@action)
    end

    def text_to_hex
      hex_spaced = @text.bytes.map { |b| format("%02X", b) }.join(" ")
      hex_compact = @text.bytes.map { |b| format("%02x", b) }.join
      hex_prefixed = @text.bytes.map { |b| format("0x%02X", b) }.join(" ")
      binary = @text.bytes.map { |b| format("%08b", b) }.join(" ")
      decimal = @text.bytes.map(&:to_s).join(" ")

      {
        valid: true,
        action: "text_to_hex",
        hex_spaced: hex_spaced,
        hex_compact: hex_compact,
        hex_prefixed: hex_prefixed,
        binary: binary,
        decimal: decimal,
        char_count: @text.length,
        byte_count: @text.bytesize
      }
    end

    def hex_to_text
      clean = @text.gsub(/\s+/, " ").strip
      clean = clean.gsub(/0x/i, "").gsub(/,\s*/, " ")

      bytes = if clean.include?(" ")
                clean.split(" ").map { |h| h.to_i(16) }
              else
                clean.scan(/../).map { |h| h.to_i(16) }
              end

      decoded = bytes.pack("C*").force_encoding("UTF-8")
      unless decoded.valid_encoding?
        decoded = decoded.encode("UTF-8", "ISO-8859-1", invalid: :replace, undef: :replace)
      end

      {
        valid: true,
        action: "hex_to_text",
        decoded: decoded,
        byte_count: bytes.length,
        char_count: decoded.length
      }
    rescue ArgumentError
      @errors << "Invalid hex input"
      { valid: false, errors: @errors }
    end
  end
end
