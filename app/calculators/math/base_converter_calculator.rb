# frozen_string_literal: true

module Math
  class BaseConverterCalculator
    attr_reader :errors

    VALID_BASES = %w[binary octal decimal hex].freeze

    def initialize(value:, input_base: "decimal")
      @raw_value = value.to_s.strip
      @input_base = input_base.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      decimal_value = to_decimal(@raw_value, @input_base)

      {
        valid: true,
        input: @raw_value,
        input_base: @input_base,
        decimal: decimal_value.to_s,
        binary: decimal_value.to_s(2),
        octal: decimal_value.to_s(8),
        hex: decimal_value.to_s(16).upcase
      }
    end

    private

    def validate!
      @errors << "Value is required" if @raw_value.empty?
      @errors << "Invalid input base. Use: binary, octal, decimal, or hex" unless VALID_BASES.include?(@input_base)
      return if @errors.any?

      unless valid_for_base?(@raw_value, @input_base)
        @errors << "Value '#{@raw_value}' is not valid for base #{@input_base}"
      end
    end

    def valid_for_base?(value, base)
      cleaned = value.sub(/\A-/, "")
      case base
      when "binary"
        cleaned.match?(/\A[01]+\z/)
      when "octal"
        cleaned.match?(/\A[0-7]+\z/)
      when "decimal"
        cleaned.match?(/\A\d+\z/)
      when "hex"
        cleaned.match?(/\A[0-9a-fA-F]+\z/)
      else
        false
      end
    end

    def to_decimal(value, base)
      radix = case base
      when "binary" then 2
      when "octal" then 8
      when "decimal" then 10
      when "hex" then 16
      end

      negative = value.start_with?("-")
      cleaned = value.sub(/\A-/, "")
      result = cleaned.to_i(radix)
      negative ? -result : result
    end
  end
end
