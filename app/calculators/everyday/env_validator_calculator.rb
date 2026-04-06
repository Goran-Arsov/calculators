# frozen_string_literal: true

module Everyday
  class EnvValidatorCalculator
    attr_reader :errors

    SENSITIVE_PATTERNS = %w[PASSWORD SECRET KEY TOKEN API_KEY PRIVATE CREDENTIAL AUTH].freeze

    def initialize(content:)
      @content = content.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      variables = []
      warnings = []
      line_errors = []
      duplicates = {}

      @content.lines.each_with_index do |raw_line, index|
        line_number = index + 1
        line = raw_line.chomp

        # Skip empty lines
        next if line.strip.empty?

        # Detect commented-out variables
        if line.strip.start_with?("#")
          if line.strip.match?(/\A#\s*[A-Z_][A-Z0-9_]*=/)
            warnings << { line: line_number, type: "commented_out", message: "Commented-out variable detected: #{line.strip}" }
          end
          next
        end

        # Lines missing = sign
        unless line.include?("=")
          line_errors << { line: line_number, type: "missing_equals", message: "Line missing '=' sign: #{line.strip}" }
          next
        end

        key, value = line.split("=", 2)
        key = key.strip
        value = value.to_s

        # Track for duplicate detection
        duplicates[key] ||= []
        duplicates[key] << line_number

        # Strip surrounding quotes from value for analysis
        stripped_value = value.strip
        unquoted_value = if stripped_value.match?(/\A["'].*["']\z/)
          stripped_value[1..-2]
        else
          stripped_value
        end

        variable = {
          key: key,
          value: stripped_value,
          line: line_number,
          status: "valid"
        }

        # Check for empty values
        if stripped_value.empty? || unquoted_value.empty?
          warnings << { line: line_number, type: "empty_value", message: "Empty value for key '#{key}'" }
          variable[:status] = "warning"
        end

        # Check for unquoted spaces
        if stripped_value.include?(" ") && !stripped_value.match?(/\A["'].*["']\z/)
          warnings << { line: line_number, type: "unquoted_spaces", message: "Value for '#{key}' contains spaces but is not quoted" }
          variable[:status] = "warning"
        end

        # Check for sensitive keys
        if SENSITIVE_PATTERNS.any? { |pattern| key.upcase.include?(pattern) }
          warnings << { line: line_number, type: "sensitive", message: "Potentially sensitive key detected: '#{key}'" }
          variable[:sensitive] = true
        end

        variables << variable
      end

      # Detect duplicate keys
      duplicates.each do |key, lines|
        next unless lines.size > 1
        lines.each do |ln|
          line_errors << { line: ln, type: "duplicate", message: "Duplicate key '#{key}' (also on line#{lines.size > 2 ? 's' : ''} #{(lines - [ ln ]).join(', ')})" }
          var = variables.find { |v| v[:key] == key && v[:line] == ln }
          var[:status] = "error" if var
        end
      end

      {
        valid: true,
        variables: variables,
        warnings: warnings,
        line_errors: line_errors,
        total_variables: variables.size,
        error_count: line_errors.size,
        warning_count: warnings.size,
        sensitive_count: variables.count { |v| v[:sensitive] }
      }
    end

    private

    def validate!
      @errors << "Content cannot be empty" if @content.strip.empty?
    end
  end
end
