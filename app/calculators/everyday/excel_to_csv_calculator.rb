# frozen_string_literal: true

module Everyday
  class ExcelToCsvCalculator
    attr_reader :errors

    def initialize(rows:, delimiter: ",")
      @rows = rows
      @delimiter = normalize_delimiter(delimiter.to_s)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      require "csv"
      csv_output = CSV.generate(col_sep: @delimiter) do |csv|
        @rows.each { |row| csv << row }
      end

      {
        valid: true,
        csv_text: csv_output,
        row_count: @rows.size,
        col_count: @rows.map(&:size).max || 0,
        delimiter: @delimiter
      }
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
      @errors << "No data provided" if @rows.nil? || @rows.empty?
      @errors << "Data must be an array of arrays" unless @rows.is_a?(Array) && @rows.all? { |r| r.is_a?(Array) }
    end
  end
end
