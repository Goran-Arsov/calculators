# frozen_string_literal: true

require "cgi"
require "json"

module Everyday
  class EscapeUnescapeCalculator
    attr_reader :errors

    SUPPORTED_FORMATS = %i[json url html backslash unicode].freeze
    SUPPORTED_ACTIONS = %i[escape unescape].freeze
    ASCII_MAX = 127

    def initialize(text:, format:, action:)
      @text = text.to_s
      @format = format.to_s.downcase.to_sym
      @action = action.to_s.downcase.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      processed = send(:"#{@action}_#{@format}")
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        output: processed,
        input_length: @text.length,
        output_length: processed.length,
        format: @format.to_s,
        action: @action.to_s
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Unsupported format: #{@format}. Supported: #{SUPPORTED_FORMATS.join(', ')}" unless SUPPORTED_FORMATS.include?(@format)
      @errors << "Unsupported action: #{@action}. Supported: #{SUPPORTED_ACTIONS.join(', ')}" unless SUPPORTED_ACTIONS.include?(@action)
    end

    # --- JSON ---

    def escape_json
      # Escape per JSON spec: quotes, backslashes, control characters
      @text.gsub("\\", "\\\\\\\\")
           .gsub('"', '\\"')
           .gsub("\n", "\\n")
           .gsub("\r", "\\r")
           .gsub("\t", "\\t")
           .gsub("\b", "\\b")
           .gsub("\f", "\\f")
    end

    def unescape_json
      # Unescape JSON escape sequences
      @text.gsub("\\n", "\n")
           .gsub("\\r", "\r")
           .gsub("\\t", "\t")
           .gsub("\\b", "\b")
           .gsub("\\f", "\f")
           .gsub('\\"', '"')
           .gsub("\\\\", "\\")
    end

    # --- URL ---

    def escape_url
      CGI.escape(@text)
    end

    def unescape_url
      CGI.unescape(@text)
    rescue ArgumentError => e
      @errors << "Invalid URL-encoded input: #{e.message}"
      ""
    end

    # --- HTML ---

    def escape_html
      CGI.escapeHTML(@text)
    end

    def unescape_html
      CGI.unescapeHTML(@text)
    end

    # --- Backslash ---

    def escape_backslash
      @text.gsub("\\", "\\\\\\\\")
           .gsub("\n", "\\n")
           .gsub("\t", "\\t")
           .gsub("\r", "\\r")
           .gsub('"', '\\"')
    end

    def unescape_backslash
      @text.gsub("\\n", "\n")
           .gsub("\\t", "\t")
           .gsub("\\r", "\r")
           .gsub('\\"', '"')
           .gsub("\\\\", "\\")
    end

    # --- Unicode ---

    def escape_unicode
      @text.each_char.map do |char|
        if char.ord > ASCII_MAX
          format("\\u%04X", char.ord)
        else
          char
        end
      end.join
    end

    def unescape_unicode
      @text.gsub(/\\u([0-9A-Fa-f]{4})/) do
        [::Regexp.last_match(1).to_i(16)].pack("U")
      end
    end
  end
end
