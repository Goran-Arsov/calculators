# frozen_string_literal: true

require "json"

module Everyday
  class CodeMinifierCalculator
    attr_reader :errors

    SUPPORTED_LANGUAGES = %i[json css html javascript].freeze
    SUPPORTED_ACTIONS = %i[minify beautify].freeze

    def initialize(code:, language:, action:)
      @code = code.to_s
      @language = language.to_s.downcase.to_sym
      @action = action.to_s.downcase.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      original_size = @code.bytesize
      processed = send(:"#{@action}_#{@language}")
      return { valid: false, errors: @errors } if @errors.any?

      processed_size = processed.bytesize
      savings = original_size.positive? ? ((original_size - processed_size).to_f / original_size * 100).round(2) : 0.0

      {
        valid: true,
        output: processed,
        original_size: original_size,
        processed_size: processed_size,
        savings_percentage: savings,
        language: @language.to_s,
        action: @action.to_s
      }
    end

    private

    def validate!
      @errors << "Code cannot be empty" if @code.strip.empty?
      @errors << "Unsupported language: #{@language}. Supported: #{SUPPORTED_LANGUAGES.join(', ')}" unless SUPPORTED_LANGUAGES.include?(@language)
      @errors << "Unsupported action: #{@action}. Supported: #{SUPPORTED_ACTIONS.join(', ')}" unless SUPPORTED_ACTIONS.include?(@action)
    end

    # --- JSON ---

    def minify_json
      parsed = JSON.parse(@code)
      JSON.generate(parsed)
    rescue JSON::ParserError => e
      @errors << "Invalid JSON: #{e.message}"
      ""
    end

    def beautify_json
      parsed = JSON.parse(@code)
      JSON.pretty_generate(parsed)
    rescue JSON::ParserError => e
      @errors << "Invalid JSON: #{e.message}"
      ""
    end

    # --- CSS ---

    def minify_css
      result = @code.dup
      result.gsub!(%r{/\*.*?\*/}m, "")       # remove block comments
      result.gsub!(/\s+/, " ")                # collapse whitespace
      result.gsub!(/\s*([{}:;,])\s*/, '\1')   # remove spaces around syntax chars
      result.gsub!(/;(?=\})/, "")             # remove trailing semicolons before }
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
        output += ("  " * indent) + stripped + "\n"
        indent += 1 if stripped.end_with?("{")
      end

      output.strip
    end

    # --- HTML ---

    def minify_html
      result = @code.dup
      result.gsub!(/<!--.*?-->/m, "")          # remove comments
      result.gsub!(/>\s+</, "><")              # collapse whitespace between tags
      result.gsub!(/\s+/, " ")                 # collapse remaining whitespace
      result.strip
    end

    def beautify_html
      result = @code.dup
      result.gsub!(/<!--.*?-->/m, "")
      result.gsub!(/>\s+</, "><")
      result.gsub!(/\s+/, " ")
      result.strip!

      # Split into tags and content
      tokens = result.scan(/(<[^>]+>|[^<]+)/).flatten.map(&:strip).reject(&:empty?)

      output = ""
      indent = 0
      void_elements = %w[area base br col embed hr img input link meta param source track wbr]

      tokens.each do |token|
        if token.start_with?("</")
          indent -= 1
          indent = 0 if indent.negative?
          output += ("  " * indent) + token + "\n"
        elsif token.start_with?("<")
          tag_name = token[/<(\w+)/, 1]&.downcase
          is_void = void_elements.include?(tag_name)
          is_self_closing = token.end_with?("/>")

          output += ("  " * indent) + token + "\n"
          indent += 1 unless is_void || is_self_closing || token.start_with?("<!")
        else
          output += ("  " * indent) + token + "\n"
        end
      end

      output.strip
    end

    # --- JavaScript ---

    def minify_javascript
      result = @code.dup

      # Remove single-line comments but preserve strings
      result = remove_js_comments(result)

      # Collapse whitespace
      result.gsub!(/\s+/, " ")
      result.gsub!(/\s*([{}();,=+\-*\/<>!&|:?])\s*/, '\1')
      result.strip
    end

    def beautify_javascript
      result = @code.dup
      result = remove_js_comments(result)
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
        output += ("  " * indent) + stripped + "\n"
        indent += 1 if stripped.end_with?("{")
      end

      output.strip
    end

    def remove_js_comments(code)
      # Remove multi-line comments
      code = code.gsub(%r{/\*.*?\*/}m, "")

      # Remove single-line comments, preserving strings
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
  end
end
