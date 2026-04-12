# frozen_string_literal: true

module Everyday
  class GraphqlBuilderCalculator
    attr_reader :errors

    OPERATION_TYPES = %w[query mutation subscription].freeze

    def initialize(operation_type:, operation_name: "", type_name:, fields: [], arguments: [], nested_fields: {})
      @operation_type = operation_type.to_s.strip.downcase
      @operation_name = operation_name.to_s.strip
      @type_name = type_name.to_s.strip
      @fields = normalize_fields(fields)
      @arguments = normalize_arguments(arguments)
      @nested_fields = normalize_nested_fields(nested_fields)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      query = build_query

      {
        valid: true,
        query: query,
        operation_type: @operation_type,
        operation_name: @operation_name,
        type_name: @type_name,
        field_count: @fields.size,
        has_arguments: @arguments.any?
      }
    end

    private

    def validate!
      @errors << "Operation type is required" if @operation_type.empty?
      @errors << "Invalid operation type: #{@operation_type}. Use: #{OPERATION_TYPES.join(', ')}" unless OPERATION_TYPES.include?(@operation_type)
      @errors << "Type name is required" if @type_name.empty?
      @errors << "At least one field is required" if @fields.empty?
    end

    def normalize_fields(fields)
      case fields
      when Array
        fields.map(&:to_s).map(&:strip).reject(&:empty?)
      when String
        fields.split(/[,\n]/).map(&:strip).reject(&:empty?)
      else
        []
      end
    end

    def normalize_arguments(arguments)
      case arguments
      when Array
        arguments.select { |a| a.is_a?(Hash) && a[:name].present? }
      when String
        arguments.split(/[,\n]/).map(&:strip).reject(&:empty?).map do |arg|
          parts = arg.split(":", 2).map(&:strip)
          { name: parts[0], value: parts[1] || "" }
        end
      else
        []
      end
    end

    def normalize_nested_fields(nested)
      case nested
      when Hash
        nested.transform_keys(&:to_s).transform_values do |fields|
          case fields
          when Array then fields.map(&:to_s).map(&:strip).reject(&:empty?)
          when String then fields.split(/[,\n]/).map(&:strip).reject(&:empty?)
          else []
          end
        end
      else
        {}
      end
    end

    def build_query
      indent = "  "
      lines = []

      # Operation line
      op_line = @operation_type
      op_line += " #{@operation_name}" if @operation_name.present?
      lines << "#{op_line} {"

      # Type with arguments
      if @arguments.any?
        args_str = @arguments.map { |a| format_argument(a) }.join(", ")
        lines << "#{indent}#{@type_name}(#{args_str}) {"
      else
        lines << "#{indent}#{@type_name} {"
      end

      # Fields
      @fields.each do |field|
        if @nested_fields.key?(field) && @nested_fields[field].any?
          lines << "#{indent}#{indent}#{field} {"
          @nested_fields[field].each do |nested_field|
            lines << "#{indent}#{indent}#{indent}#{nested_field}"
          end
          lines << "#{indent}#{indent}}"
        else
          lines << "#{indent}#{indent}#{field}"
        end
      end

      lines << "#{indent}}"
      lines << "}"

      lines.join("\n")
    end

    def format_argument(arg)
      name = arg[:name].to_s
      value = arg[:value].to_s
      type = arg[:type].to_s

      formatted_value = case type.downcase
                         when "int", "integer", "float", "number"
                           value
                         when "boolean", "bool"
                           value.downcase
                         when "enum"
                           value
                         else
                           value =~ /\A-?\d+(\.\d+)?\z/ || %w[true false null].include?(value.downcase) ? value : "\"#{value}\""
                         end

      "#{name}: #{formatted_value}"
    end
  end
end
