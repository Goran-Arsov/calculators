# frozen_string_literal: true

module Everyday
  class ExcelToPdfCalculator
    attr_reader :errors

    def initialize(rows:)
      @rows = rows
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      {
        valid: true,
        row_count: @rows.size,
        col_count: @rows.map(&:size).max || 0
      }
    end

    private

    def validate!
      @errors << "No data provided" if @rows.nil? || @rows.empty?
      @errors << "Data must be an array of arrays" unless @rows.is_a?(Array) && @rows.all? { |r| r.is_a?(Array) }
    end
  end
end
