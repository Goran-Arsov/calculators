# frozen_string_literal: true

module Everyday
  class CssFormatterCalculator
    attr_reader :errors

    SUPPORTED_ACTIONS = %i[beautify minify].freeze
    INDENT = "  "

    def initialize(code:, action:)
      @code = code.to_s
      @action = action.to_s.downcase.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      original_size = @code.bytesize
      processed = send(:"#{@action}_css")
      processed_size = processed.bytesize
      savings = original_size.positive? ? ((original_size - processed_size).to_f / original_size * 100).round(2) : 0.0

      {
        valid: true,
        output: processed,
        original_size: original_size,
        processed_size: processed_size,
        savings_percentage: savings,
        action: @action.to_s,
        rule_count: count_rules(@code),
        selector_count: count_selectors(@code)
      }
    end

    private

    def validate!
      @errors << "Code cannot be empty" if @code.strip.empty?
      @errors << "Unsupported action: #{@action}. Supported: #{SUPPORTED_ACTIONS.join(', ')}" unless SUPPORTED_ACTIONS.include?(@action)
    end

    def minify_css
      result = @code.dup
      result.gsub!(%r{/\*.*?\*/}m, "")
      result.gsub!(/\s+/, " ")
      result.gsub!(/\s*([{}:;,])\s*/, '\1')
      result.gsub!(/;(?=\})/, "")
      result.strip
    end

    def beautify_css
      result = @code.dup
      result.gsub!(%r{/\*.*?\*/}m, "")
      result.gsub!(/\s+/, " ")
      result.strip!

      output = ""
      indent = 0

      result.gsub!(/\s*\{\s*/, " {\n")
      result.gsub!(/\s*\}\s*/, "\n}\n")
      result.gsub!(/\s*;\s*/, ";\n")

      result.each_line do |line|
        stripped = line.strip
        next if stripped.empty?

        indent -= 1 if stripped.start_with?("}")
        indent = 0 if indent.negative?
        output += (INDENT * indent) + stripped + "\n"
        indent += 1 if stripped.end_with?("{")
      end

      output.strip
    end

    def count_rules(css)
      clean = css.gsub(%r{/\*.*?\*/}m, "")
      clean.scan(/\{/).length
    end

    def count_selectors(css)
      clean = css.gsub(%r{/\*.*?\*/}m, "")
      clean.scan(/[^{}]+(?=\s*\{)/).length
    end
  end
end
