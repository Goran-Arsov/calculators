# frozen_string_literal: true

require "yaml"
require "json"

module Everyday
  class YamlToJsonCalculator
    attr_reader :errors

    DIRECTIONS = %i[yaml_to_json json_to_yaml].freeze

    def initialize(text:, direction: :yaml_to_json)
      @text = text.to_s
      @direction = direction.to_sym
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @direction
      when :yaml_to_json
        convert_yaml_to_json
      when :json_to_yaml
        convert_json_to_yaml
      end
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Invalid direction: #{@direction}. Use :yaml_to_json or :json_to_yaml" unless DIRECTIONS.include?(@direction)
    end

    def convert_yaml_to_json
      parsed = YAML.safe_load(@text, permitted_classes: [ Date, Time, Symbol ])
      json_output = JSON.pretty_generate(parsed)
      {
        valid: true,
        output: json_output,
        direction: :yaml_to_json,
        input_lines: @text.lines.count,
        output_lines: json_output.lines.count
      }
    rescue Psych::SyntaxError => e
      @errors << "Invalid YAML: #{e.message}"
      { valid: false, errors: @errors }
    end

    def convert_json_to_yaml
      parsed = JSON.parse(@text)
      yaml_output = Psych.dump(parsed, line_width: -1)
      {
        valid: true,
        output: yaml_output,
        direction: :json_to_yaml,
        input_lines: @text.lines.count,
        output_lines: yaml_output.lines.count
      }
    rescue JSON::ParserError => e
      @errors << "Invalid JSON: #{e.message}"
      { valid: false, errors: @errors }
    end
  end
end
