# frozen_string_literal: true

module Everyday
  class ByteConverterCalculator
    attr_reader :errors

    BINARY_UNITS  = %w[B KiB MiB GiB TiB PiB].freeze
    DECIMAL_UNITS = %w[B KB MB GB TB PB].freeze
    INPUT_UNITS   = %w[B KB MB GB TB PB].freeze

    # Input units use 1024-based (binary) interpretation
    TO_BYTES_BINARY = {
      "B"  => 1,
      "KB" => 1024,
      "MB" => 1024**2,
      "GB" => 1024**3,
      "TB" => 1024**4,
      "PB" => 1024**5
    }.freeze

    BINARY_FACTORS = {
      "B"   => 1,
      "KiB" => 1024,
      "MiB" => 1024**2,
      "GiB" => 1024**3,
      "TiB" => 1024**4,
      "PiB" => 1024**5
    }.freeze

    DECIMAL_FACTORS = {
      "B"  => 1,
      "KB" => 1000,
      "MB" => 1000**2,
      "GB" => 1000**3,
      "TB" => 1000**4,
      "PB" => 1000**5
    }.freeze

    def initialize(value:, from_unit:)
      @value = value.to_f
      @from_unit = from_unit.to_s.upcase.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      bytes = @value * TO_BYTES_BINARY[@from_unit]

      binary = BINARY_FACTORS.each_with_object({}) do |(unit, factor), hash|
        hash[unit.to_sym] = (bytes.to_f / factor).round(6)
      end

      decimal = DECIMAL_FACTORS.each_with_object({}) do |(unit, factor), hash|
        hash[unit.to_sym] = (bytes.to_f / factor).round(6)
      end

      {
        valid: true,
        binary: binary,
        decimal: decimal,
        from_unit: @from_unit,
        original_value: @value
      }
    end

    private

    def validate!
      @errors << "Value must be zero or greater" if @value.negative?
      @errors << "Unknown unit: #{@from_unit}. Valid: #{INPUT_UNITS.join(', ')}" unless INPUT_UNITS.include?(@from_unit)
    end
  end
end
