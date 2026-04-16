# frozen_string_literal: true

module Math
  class PermutationCombinationCalculator
    attr_reader :errors

    def initialize(n:, r:)
      @n = n.to_i
      @r = r.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      n_factorial = factorial(@n)
      r_factorial = factorial(@r)
      n_minus_r_factorial = factorial(@n - @r)

      permutation = n_factorial / n_minus_r_factorial
      combination = n_factorial / (r_factorial * n_minus_r_factorial)

      {
        valid: true,
        n: @n,
        r: @r,
        permutation: permutation,
        combination: combination,
        n_factorial: n_factorial,
        r_factorial: r_factorial,
        n_minus_r_factorial: n_minus_r_factorial
      }
    end

    private

    def validate!
      @errors << "n must be a non-negative integer" if @n < 0
      @errors << "r must be a non-negative integer" if @r < 0
      @errors << "r cannot be greater than n" if @r > @n && @n >= 0 && @r >= 0
    end

    def factorial(num)
      return 1 if num <= 1
      (2..num).reduce(1, :*)
    end
  end
end
