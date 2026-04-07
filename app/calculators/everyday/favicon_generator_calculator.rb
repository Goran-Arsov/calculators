# frozen_string_literal: true

module Everyday
  class FaviconGeneratorCalculator
    attr_reader :errors

    SIZES = [ 16, 32, 48, 180 ].freeze

    def initialize(text:, bg_color:, text_color:, font_size: 64)
      @text = text.to_s.strip
      @bg_color = bg_color.to_s.strip
      @text_color = text_color.to_s.strip
      @font_size = font_size.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        text: @text,
        bg_color: @bg_color,
        text_color: @text_color,
        font_size: @font_size,
        sizes: SIZES,
        html_tags: build_html_tags
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.empty?
      @errors << "Text must be 1-2 characters" if @text.length > 2
      unless @bg_color.match?(/\A#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/)
        @errors << "Background color must be a valid hex value"
      end
      unless @text_color.match?(/\A#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\z/)
        @errors << "Text color must be a valid hex value"
      end
      @errors << "Font size must be between 8 and 200" unless @font_size.between?(8, 200)
    end

    def build_html_tags
      lines = []
      lines << %(<link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">)
      lines << %(<link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">)
      lines << %(<link rel="icon" type="image/png" sizes="48x48" href="/favicon-48x48.png">)
      lines << %(<link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png">)
      lines.join("\n")
    end
  end
end
