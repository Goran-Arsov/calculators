# frozen_string_literal: true

require "json"

module Everyday
  class JsonValidatorCalculator
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
        return {
          valid: true,
          json_valid: false,
          error_message: e.message,
          error_line: extract_line_number(e.message)
        }
      end

      {
        valid: true,
        json_valid: true,
        formatted: JSON.pretty_generate(parsed),
        key_count: count_keys(parsed),
        nesting_depth: nesting_depth(parsed),
        root_type: root_type(parsed),
        size_bytes: @text.bytesize
      }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
    end

    def extract_line_number(message)
      match = message.match(/at line (\d+)/)
      match ? match[1].to_i : nil
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

    def nesting_depth(obj, current = 1)
      case obj
      when Hash
        return current if obj.empty?
        [ current, obj.values.map { |v| nesting_depth(v, current + 1) }.max ].max
      when Array
        return current if obj.empty?
        [ current, obj.map { |v| nesting_depth(v, current + 1) }.max ].max
      else
        current
      end
    end

    def root_type(obj)
      case obj
      when Hash then "Object"
      when Array then "Array"
      when String then "String"
      when Numeric then "Number"
      when TrueClass, FalseClass then "Boolean"
      when NilClass then "Null"
      end
    end
  end
end
