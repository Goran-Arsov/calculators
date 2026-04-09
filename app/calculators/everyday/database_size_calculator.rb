# frozen_string_literal: true

module Everyday
  class DatabaseSizeCalculator
    attr_reader :errors

    FIXED_TYPE_BYTES = {
      "integer"   => 4,
      "bigint"    => 8,
      "boolean"   => 1,
      "timestamp" => 8,
      "float"     => 8,
      "uuid"      => 16
    }.freeze

    VARIABLE_TYPES = %w[varchar text].freeze

    ALL_TYPES = (FIXED_TYPE_BYTES.keys + VARIABLE_TYPES).freeze

    POSTGRESQL_ROW_OVERHEAD = 23  # HeapTupleHeaderData
    INDEX_OVERHEAD_FACTOR = 1.3   # 30% for indexes

    def initialize(num_rows:, columns:)
      @num_rows = num_rows.to_i
      @columns = Array(columns)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bytes_per_row = calculate_row_bytes
      return { valid: false, errors: @errors } if @errors.any?

      raw_row_bytes = bytes_per_row + POSTGRESQL_ROW_OVERHEAD
      raw_table_size_bytes = raw_row_bytes * @num_rows
      with_index_size_bytes = (raw_table_size_bytes * INDEX_OVERHEAD_FACTOR).round

      {
        valid: true,
        bytes_per_row: bytes_per_row,
        raw_row_bytes_with_overhead: raw_row_bytes,
        raw_table_size_bytes: raw_table_size_bytes,
        with_index_size_bytes: with_index_size_bytes,
        formatted_raw_size: format_bytes(raw_table_size_bytes),
        formatted_with_index_size: format_bytes(with_index_size_bytes),
        num_rows: @num_rows,
        column_count: @columns.length
      }
    end

    private

    def validate!
      @errors << "Number of rows must be greater than zero" unless @num_rows.positive?
      @errors << "At least one column is required" if @columns.empty?
    end

    def calculate_row_bytes
      total = 0
      @columns.each_with_index do |col, i|
        type = col[:type].to_s.downcase.strip
        avg_bytes = col[:avg_bytes].to_i

        unless ALL_TYPES.include?(type)
          @errors << "Unknown column type at position #{i + 1}: '#{type}'. Valid types: #{ALL_TYPES.join(', ')}"
          return 0
        end

        if FIXED_TYPE_BYTES.key?(type)
          total += FIXED_TYPE_BYTES[type]
        else
          if avg_bytes <= 0
            @errors << "Average bytes must be positive for #{type} column at position #{i + 1}"
            return 0
          end
          total += avg_bytes
        end
      end
      total
    end

    def format_bytes(bytes)
      if bytes >= 1_073_741_824
        "#{(bytes / 1_073_741_824.0).round(2)} GB"
      elsif bytes >= 1_048_576
        "#{(bytes / 1_048_576.0).round(2)} MB"
      elsif bytes >= 1_024
        "#{(bytes / 1_024.0).round(2)} KB"
      else
        "#{bytes} B"
      end
    end
  end
end
