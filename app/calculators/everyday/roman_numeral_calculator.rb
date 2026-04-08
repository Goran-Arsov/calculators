# frozen_string_literal: true

module Everyday
  class RomanNumeralCalculator
    attr_reader :errors

    ROMAN_VALUES = [
      [ "M", 1000 ], [ "CM", 900 ], [ "D", 500 ], [ "CD", 400 ],
      [ "C", 100 ],  [ "XC", 90 ],  [ "L", 50 ],  [ "XL", 40 ],
      [ "X", 10 ],   [ "IX", 9 ],   [ "V", 5 ],   [ "IV", 4 ],
      [ "I", 1 ]
    ].freeze

    VALID_ROMAN_PATTERN = /\A(M{0,3})(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\z/i

    MIN_VALUE = 1
    MAX_VALUE = 3999

    def initialize(input:)
      @input = input.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if numeric_input?
        integer_to_roman
      else
        roman_to_integer
      end
    end

    private

    def validate!
      @errors << "Input cannot be empty" if @input.empty?
      return if @input.empty?

      if numeric_input?
        value = @input.to_i
        if value < MIN_VALUE
          @errors << "Number must be at least #{MIN_VALUE}"
        elsif value > MAX_VALUE
          @errors << "Number must be at most #{MAX_VALUE}"
        end
      else
        unless @input.match?(VALID_ROMAN_PATTERN) && !@input.empty?
          @errors << "Invalid roman numeral format"
        end
      end
    end

    def numeric_input?
      @input.match?(/\A\d+\z/)
    end

    def integer_to_roman
      number = @input.to_i
      result = +""
      remaining = number

      ROMAN_VALUES.each do |roman, value|
        while remaining >= value
          result << roman
          remaining -= value
        end
      end

      {
        valid: true,
        direction: :to_roman,
        integer: number,
        roman: result
      }
    end

    def roman_to_integer
      roman = @input.upcase
      total = 0
      i = 0

      while i < roman.length
        if i + 1 < roman.length
          two_char = roman[i, 2]
          match = ROMAN_VALUES.find { |r, _| r == two_char }
          if match
            total += match[1]
            i += 2
            next
          end
        end

        one_char = roman[i]
        match = ROMAN_VALUES.find { |r, _| r == one_char }
        total += match[1] if match
        i += 1
      end

      {
        valid: true,
        direction: :to_integer,
        roman: @input.upcase,
        integer: total
      }
    end
  end
end
