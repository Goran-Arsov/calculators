# frozen_string_literal: true

require "csv"
require "json"

module Everyday
  class CsvToJsonCalculator
    attr_reader :errors

    DELIMITERS = {
      "comma" => ",",
      "tab" => "\t",
      "semicolon" => ";",
      "pipe" => "|"
    }.freeze

    def initialize(text:, has_headers: true, delimiter: "comma")
      @text = text.to_s
      @has_headers = has_headers.to_s == "true" || has_headers == true
      @delimiter = delimiter.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      col_sep = DELIMITERS[@delimiter]
      rows = CSV.parse(@text, col_sep: col_sep)

      if rows.empty?
        @errors << "CSV contains no data rows"
        return { valid: false, errors: @errors }
      end

      if @has_headers
        convert_with_headers(rows)
      else
        convert_without_headers(rows)
      end
    rescue CSV::MalformedCSVError => e
      @errors << "Invalid CSV: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "Text cannot be empty" if @text.strip.empty?
      @errors << "Unsupported delimiter: #{@delimiter}. Supported: #{DELIMITERS.keys.join(', ')}" unless DELIMITERS.key?(@delimiter)
    end

    def convert_with_headers(rows)
      headers = rows.first
      data_rows = rows[1..]

      if data_rows.nil? || data_rows.empty?
        @errors << "CSV has headers but no data rows"
        return { valid: false, errors: @errors }
      end

      result = data_rows.map { |row| headers.zip(row).to_h }
      json_output = JSON.pretty_generate(result)

      {
        valid: true,
        output: json_output,
        row_count: data_rows.length,
        column_count: headers.length,
        headers: headers,
        has_headers: true
      }
    end

    def convert_without_headers(rows)
      json_output = JSON.pretty_generate(rows)

      {
        valid: true,
        output: json_output,
        row_count: rows.length,
        column_count: rows.first&.length || 0,
        headers: nil,
        has_headers: false
      }
    end
  end
end
