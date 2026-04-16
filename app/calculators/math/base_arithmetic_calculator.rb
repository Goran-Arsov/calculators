# frozen_string_literal: true

module Math
  class BaseArithmeticCalculator
    OPERATIONS = %w[add subtract multiply].freeze
    MIN_BASE = 2
    MAX_BASE = 36
    DIGITS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    attr_reader :errors

    def initialize(number1:, number2:, base:, operation:)
      @number1_str = number1.to_s.strip.upcase
      @number2_str = number2.to_s.strip.upcase
      @base = base.to_i
      @operation = operation.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      num1_decimal = to_decimal(@number1_str, @base)
      num2_decimal = to_decimal(@number2_str, @base)

      result_decimal = case @operation
      when "add" then num1_decimal + num2_decimal
      when "subtract" then num1_decimal - num2_decimal
      when "multiply" then num1_decimal * num2_decimal
      end

      result_in_base = from_decimal(result_decimal, @base)

      {
        valid: true,
        number1: @number1_str,
        number2: @number2_str,
        base: @base,
        operation: @operation,
        result: result_in_base,
        number1_decimal: num1_decimal,
        number2_decimal: num2_decimal,
        result_decimal: result_decimal,
        base_name: base_name(@base),
        display: "#{@number1_str} #{operation_symbol} #{@number2_str} = #{result_in_base} (base #{@base})"
      }
    end

    private

    def validate!
      @errors << "Operation cannot be blank" if @operation.empty?
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
      @errors << "Base must be between #{MIN_BASE} and #{MAX_BASE}" unless @base.between?(MIN_BASE, MAX_BASE)
      @errors << "Number 1 cannot be blank" if @number1_str.empty?
      @errors << "Number 2 cannot be blank" if @number2_str.empty?

      if @base.between?(MIN_BASE, MAX_BASE)
        validate_digits(@number1_str, @base, "Number 1") unless @number1_str.empty?
        validate_digits(@number2_str, @base, "Number 2") unless @number2_str.empty?
      end
    end

    def validate_digits(num_str, base, label)
      valid_digits = DIGITS[0, base]
      clean = num_str.sub(/\A-/, "")
      clean.each_char do |ch|
        unless valid_digits.include?(ch)
          @errors << "#{label} contains invalid digit '#{ch}' for base #{base} (valid: #{valid_digits})"
          return
        end
      end
    end

    def to_decimal(num_str, base)
      negative = num_str.start_with?("-")
      clean = negative ? num_str[1..] : num_str
      result = 0
      clean.each_char do |ch|
        result = result * base + DIGITS.index(ch)
      end
      negative ? -result : result
    end

    def from_decimal(decimal, base)
      return "0" if decimal.zero?

      negative = decimal < 0
      decimal = decimal.abs
      digits = []

      while decimal > 0
        digits.unshift(DIGITS[decimal % base])
        decimal /= base
      end

      result = digits.join
      negative ? "-#{result}" : result
    end

    def operation_symbol
      case @operation
      when "add" then "+"
      when "subtract" then "-"
      when "multiply" then "*"
      end
    end

    def base_name(base)
      case base
      when 2 then "Binary"
      when 8 then "Octal"
      when 10 then "Decimal"
      when 16 then "Hexadecimal"
      else "Base #{base}"
      end
    end
  end
end
