# frozen_string_literal: true

module Everyday
  class CsvToPdfCalculator
    attr_reader :errors

    def initialize(csv_text:, delimiter: ",")
      @csv_text = csv_text.to_s
      @delimiter = normalize_delimiter(delimiter.to_s)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      require "csv"
      rows = CSV.parse(@csv_text, col_sep: @delimiter)

      {
        valid: true,
        rows: rows,
        row_count: rows.size,
        col_count: rows.map(&:size).max || 0
      }
    rescue CSV::MalformedCSVError => e
      @errors << "Invalid CSV: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def normalize_delimiter(delim)
      case delim
      when "tab", "\\t", "\t" then "\t"
      when "semicolon", ";" then ";"
      when "pipe", "|" then "|"
      else ","
      end
    end

    def validate!
      @errors << "CSV text cannot be empty" if @csv_text.strip.empty?
    end
  end
end
