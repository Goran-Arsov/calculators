# frozen_string_literal: true

require "json"

module Everyday
  class JsonToTypescriptCalculator
    attr_reader :errors

    def initialize(text:, root_name: "Root")
      @text = text.to_s
      @root_name = root_name.to_s.strip
      @root_name = "Root" if @root_name.empty?
      @errors = []
      @interfaces = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      begin
        parsed = JSON.parse(@text)
      rescue JSON::ParserError => e
        @errors << "Invalid JSON: #{e.message}"
        return { valid: false, errors: @errors }
      end

      generate_interface(@root_name, parsed)

      output = @interfaces.reverse.map { |i| i[:code] }.join("\n\n")

      {
        valid: true,
        typescript: output,
        interface_count: @interfaces.size,
        root_type: parsed.is_a?(Array) ? "Array" : "Object"
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def generate_interface(name, value)
      case value
      when Hash
        lines = [ "interface #{pascalize(name)} {" ]
        value.each do |key, val|
          ts_type = infer_type(key, val)
          safe_key = key.match?(/\A[a-zA-Z_$][a-zA-Z0-9_$]*\z/) ? key : "\"#{key}\""
          lines << "  #{safe_key}: #{ts_type};"
        end
        lines << "}"
        @interfaces << { name: pascalize(name), code: lines.join("\n") }
        pascalize(name)
      when Array
        if value.empty?
          "any[]"
        else
          element_type = infer_type(name.sub(/s\z/, ""), value.first)
          "#{element_type}[]"
        end
      else
        infer_primitive(value)
      end
    end

    def infer_type(key, value)
      case value
      when Hash
        generate_interface(key, value)
      when Array
        if value.empty?
          "any[]"
        elsif value.first.is_a?(Hash)
          element_name = singularize(key)
          generate_interface(element_name, value.first)
          "#{pascalize(element_name)}[]"
        else
          "#{infer_primitive(value.first)}[]"
        end
      else
        infer_primitive(value)
      end
    end

    def infer_primitive(value)
      case value
      when String then "string"
      when Integer, Float then "number"
      when TrueClass, FalseClass then "boolean"
      when NilClass then "null"
      else "any"
      end
    end

    def pascalize(str)
      str.to_s.gsub(/[-_\s]+/, "_").split("_").map(&:capitalize).join
    end

    def singularize(str)
      s = str.to_s
      if s.end_with?("ies")
        s.sub(/ies\z/, "y")
      elsif s.end_with?("ses")
        s.sub(/ses\z/, "s")
      elsif s.end_with?("s") && !s.end_with?("ss")
        s.sub(/s\z/, "")
      else
        s
      end
    end
  end
end
