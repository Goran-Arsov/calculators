# frozen_string_literal: true

module Everyday
  class JsFormatterCalculator
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
      processed = send(:"#{@action}_js")
      processed_size = processed.bytesize
      savings = original_size.positive? ? ((original_size - processed_size).to_f / original_size * 100).round(2) : 0.0

      {
        valid: true,
        output: processed,
        original_size: original_size,
        processed_size: processed_size,
        savings_percentage: savings,
        action: @action.to_s,
        line_count: processed.lines.count,
        function_count: count_functions(@code)
      }
    end

    private

    def validate!
      @errors << "Code cannot be empty" if @code.strip.empty?
      @errors << "Unsupported action: #{@action}. Supported: #{SUPPORTED_ACTIONS.join(', ')}" unless SUPPORTED_ACTIONS.include?(@action)
    end

    def minify_js
      result = @code.dup
      result = remove_comments(result)
      result.gsub!(/\s+/, " ")
      result.gsub!(/\s*([{}();,=+\-*\/<>!&|:?])\s*/, '\1')
      result.strip
    end

    def beautify_js
      result = @code.dup
      result = remove_comments(result)
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

    def remove_comments(code)
      code = code.gsub(%r{/\*.*?\*/}m, "")

      lines = code.lines.map do |line|
        in_string = false
        string_char = nil
        i = 0
        while i < line.length
          char = line[i]

          if in_string
            if char == "\\" # skip escaped characters
              i += 2
              next
            end
            in_string = false if char == string_char
          elsif char == '"' || char == "'"
            in_string = true
            string_char = char
          elsif char == "/" && line[i + 1] == "/"
            line = line[0...i]
            break
          end

          i += 1
        end

        line
      end

      lines.join
    end

    def count_functions(code)
      clean = remove_comments(code)
      declarations = clean.scan(/\bfunction\b/).length
      arrows = clean.scan(/=>/).length
      declarations + arrows
    end
  end
end
