# frozen_string_literal: true

module Math
  class ExponentCalculator
    attr_reader :errors

    def initialize(base:, exponent:)
      @base = base.to_f
      @exponent = exponent.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = @base**@exponent

      if result.infinite? || result.nan?
        @errors << "Result is too large or undefined"
        return { valid: false, errors: @errors }
      end

      {
        valid: true,
        result: result,
        base: @base,
        exponent: @exponent
      }
    end

    private

    def validate!
      @errors << "Cannot raise zero to a negative power" if @base.zero? && @exponent < 0
      @errors << "Cannot raise negative number to fractional power" if @base < 0 && @exponent != @exponent.to_i
    end
  end
end
