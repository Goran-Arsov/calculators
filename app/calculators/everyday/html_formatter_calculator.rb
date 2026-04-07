# frozen_string_literal: true

module Everyday
  class HtmlFormatterCalculator
    attr_reader :errors

    SUPPORTED_ACTIONS = %i[beautify minify].freeze
    INDENT = "  "
    VOID_ELEMENTS = %w[area base br col embed hr img input link meta param source track wbr].freeze

    def initialize(code:, action:)
      @code = code.to_s
      @action = action.to_s.downcase.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      original_size = @code.bytesize
      processed = send(:"#{@action}_html")
      processed_size = processed.bytesize
      savings = original_size.positive? ? ((original_size - processed_size).to_f / original_size * 100).round(2) : 0.0

      {
        valid: true,
        output: processed,
        original_size: original_size,
        processed_size: processed_size,
        savings_percentage: savings,
        action: @action.to_s,
        tag_count: count_tags(@code),
        has_doctype: @code.strip.downcase.start_with?("<!doctype")
      }
    end

    private

    def validate!
      @errors << "Code cannot be empty" if @code.strip.empty?
      @errors << "Unsupported action: #{@action}. Supported: #{SUPPORTED_ACTIONS.join(', ')}" unless SUPPORTED_ACTIONS.include?(@action)
    end

    def minify_html
      result = @code.dup
      result.gsub!(/<!--.*?-->/m, "")
      result.gsub!(/>\s+</, "><")
      result.gsub!(/\s+/, " ")
      result.strip
    end

    def beautify_html
      result = @code.dup
      result.gsub!(/<!--.*?-->/m, "")
      result.gsub!(/>\s+</, "><")
      result.gsub!(/\s+/, " ")
      result.strip!

      tokens = result.scan(/(<[^>]+>|[^<]+)/).flatten.map(&:strip).reject(&:empty?)

      output = ""
      indent = 0

      tokens.each do |token|
        if token.start_with?("</")
          indent -= 1
          indent = 0 if indent.negative?
          output += (INDENT * indent) + token + "\n"
        elsif token.start_with?("<")
          tag_name = token[/<(\w+)/, 1]&.downcase
          is_void = VOID_ELEMENTS.include?(tag_name)
          is_self_closing = token.end_with?("/>")

          output += (INDENT * indent) + token + "\n"
          indent += 1 unless is_void || is_self_closing || token.start_with?("<!")
        else
          output += (INDENT * indent) + token + "\n"
        end
      end

      output.strip
    end

    def count_tags(html)
      html.scan(/<[a-zA-Z][^>]*>/).length
    end
  end
end
