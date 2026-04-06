# frozen_string_literal: true

require "cgi"

module Everyday
  class HtmlEntityEncoderCalculator
    attr_reader :errors

    NAMED_ENTITIES = {
      "&" => "&amp;", "<" => "&lt;", ">" => "&gt;",
      '"' => "&quot;", "'" => "&apos;", " " => "&nbsp;",
      "\u00a9" => "&copy;", "\u00ae" => "&reg;", "\u2122" => "&trade;",
      "\u00b0" => "&deg;", "\u00b1" => "&plusmn;", "\u00d7" => "&times;",
      "\u00f7" => "&divide;", "\u2013" => "&ndash;", "\u2014" => "&mdash;",
      "\u2018" => "&lsquo;", "\u2019" => "&rsquo;", "\u201c" => "&ldquo;",
      "\u201d" => "&rdquo;", "\u2026" => "&hellip;", "\u2022" => "&bull;",
      "\u20ac" => "&euro;", "\u00a3" => "&pound;", "\u00a5" => "&yen;",
      "\u00a2" => "&cent;", "\u00ab" => "&laquo;", "\u00bb" => "&raquo;",
      "\u00bc" => "&frac14;", "\u00bd" => "&frac12;", "\u00be" => "&frac34;"
    }.freeze

    REVERSE_NAMED_ENTITIES = NAMED_ENTITIES.invert.freeze

    def initialize(text:, direction: :encode)
      @text = text.to_s
      @direction = direction.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @direction
      when :encode
        encode_text
      when :decode
        decode_text
      else
        @errors << "Invalid direction. Use :encode or :decode"
        { valid: false, errors: @errors }
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def encode_text
      named = encode_named_entities(@text)
      numeric = encode_numeric_entities(@text)
      basic = CGI.escapeHTML(@text)

      {
        valid: true,
        original: @text,
        named_entities: named,
        numeric_entities: numeric,
        basic_escaped: basic,
        character_count: @text.length,
        encoded_character_count: named.length,
        entities_used: count_entities(named)
      }
    end

    def decode_text
      decoded = decode_all_entities(@text)

      {
        valid: true,
        original: @text,
        decoded: decoded,
        character_count: @text.length,
        decoded_character_count: decoded.length,
        entities_found: count_entities_in_encoded(@text)
      }
    end

    def encode_named_entities(text)
      result = text.dup
      NAMED_ENTITIES.each do |char, entity|
        result.gsub!(char, entity)
      end
      result.gsub!(/[^\x20-\x7E\n\r\t]/) do |char|
        if NAMED_ENTITIES.key?(char)
          NAMED_ENTITIES[char]
        else
          "&##{char.ord};"
        end
      end
      result
    end

    def encode_numeric_entities(text)
      result = text.dup
      result.gsub!("&", "&#38;")
      result.gsub!("<", "&#60;")
      result.gsub!(">", "&#62;")
      result.gsub!('"', "&#34;")
      result.gsub!("'", "&#39;")
      result.gsub!(/[^\x20-\x7E\n\r\t]/) do |char|
        "&##{char.ord};"
      end
      result
    end

    def decode_all_entities(text)
      result = CGI.unescapeHTML(text)

      result.gsub!(/&apos;/, "'")

      REVERSE_NAMED_ENTITIES.each do |entity, char|
        result.gsub!(entity, char)
      end

      result.gsub!(/&#(\d+);/) do
        [$1.to_i].pack("U")
      end

      result.gsub!(/&#x([0-9a-fA-F]+);/) do
        [$1.to_i(16)].pack("U")
      end

      result
    end

    def count_entities(text)
      text.scan(/&[#\w]+;/).length
    end

    def count_entities_in_encoded(text)
      text.scan(/&[#\w]+;/).length
    end
  end
end
