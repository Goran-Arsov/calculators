# frozen_string_literal: true

require "json"

module Everyday
  class JsonFormatterCalculator
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

      {
        valid: true,
        formatted: JSON.pretty_generate(parsed),
        minified: JSON.generate(parsed),
        key_count: count_keys(parsed),
        nesting_depth: nesting_depth(parsed),
        is_array: parsed.is_a?(Array),
        is_object: parsed.is_a?(Hash)
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

    def nesting_depth(obj, current = 1)
      case obj
      when Hash
        return current if obj.empty?
        current_max = obj.values.map { |v| nesting_depth(v, current + 1) }.max
        [current, current_max].max
      when Array
        return current if obj.empty?
        current_max = obj.map { |v| nesting_depth(v, current + 1) }.max
        [current, current_max].max
      else
        current
      end
    end
  end
end
