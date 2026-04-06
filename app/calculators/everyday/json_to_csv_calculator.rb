# frozen_string_literal: true

require "json"
require "csv"

module Everyday
  class JsonToCsvCalculator
    attr_reader :errors

    DELIMITERS = {
      "comma" => ",",
      "tab" => "\t",
      "semicolon" => ";",
      "pipe" => "|"
    }.freeze

    def initialize(json:, delimiter: "comma")
      @json = json.to_s
      @delimiter = delimiter.to_s.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      parsed = JSON.parse(@json)

      unless parsed.is_a?(Array)
        @errors << "JSON must be an array of objects"
        return { valid: false, errors: @errors }
      end

      if parsed.empty?
        @errors << "JSON array is empty"
        return { valid: false, errors: @errors }
      end

      unless parsed.all? { |item| item.is_a?(Hash) }
        @errors << "All items in the JSON array must be objects"
        return { valid: false, errors: @errors }
      end

      headers = extract_headers(parsed)
      csv_text = generate_csv(parsed, headers)

      {
        valid: true,
        csv_text: csv_text,
        row_count: parsed.length,
        col_count: headers.length,
        headers: headers
      }
    rescue JSON::ParserError => e
      @errors << "Invalid JSON: #{e.message}"
      { valid: false, errors: @errors }
    end

    private

    def validate!
      @errors << "JSON cannot be empty" if @json.strip.empty?
      @errors << "Unsupported delimiter: #{@delimiter}. Supported: #{DELIMITERS.keys.join(', ')}" unless DELIMITERS.key?(@delimiter)
    end

    def extract_headers(array_of_hashes)
      headers = []
      array_of_hashes.each do |obj|
        obj.each_key do |key|
          headers << key unless headers.include?(key)
        end
      end
      headers
    end

    def generate_csv(data, headers)
      col_sep = DELIMITERS[@delimiter]

      CSV.generate(col_sep: col_sep) do |csv|
        csv << headers
        data.each do |obj|
          csv << headers.map { |h| obj[h]&.to_s || "" }
        end
      end
    end
  end
end
