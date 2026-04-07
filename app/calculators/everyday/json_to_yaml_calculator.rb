# frozen_string_literal: true

require "json"
require "yaml"

module Everyday
  class JsonToYamlCalculator
    attr_reader :errors

    def initialize(text:)
      @text = text.to_s
      @errors = []
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

      yaml_output = YAML.dump(parsed)
      # Remove the leading "---\n" for cleaner output
      yaml_clean = yaml_output.sub(/\A---\n/, "")

      {
        valid: true,
        yaml: yaml_output,
        yaml_clean: yaml_clean,
        json_size: @text.bytesize,
        yaml_size: yaml_output.bytesize,
        key_count: count_keys(parsed),
        root_type: parsed.is_a?(Array) ? "Array" : "Object"
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def count_keys(obj)
      case obj
      when Hash
        obj.size + obj.values.sum { |v| count_keys(v) }
      when Array
        obj.sum { |v| count_keys(v) }
      else
        0
      end
    end
  end
end
