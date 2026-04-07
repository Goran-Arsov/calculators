# frozen_string_literal: true

module Everyday
  class PrimeCheckerCalculator
    attr_reader :errors

    MAX_NUMBER = 10_000_000_000

    def initialize(number:)
      @number = number.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      is_prime = prime?(@number)
      factors = is_prime ? [@number] : factorize(@number)

      result = {
        valid: true,
        number: @number,
        is_prime: is_prime,
        factors: factors,
        nearest_prime_below: nearest_prime_below(@number),
        nearest_prime_above: nearest_prime_above(@number)
      }

      result[:prime_index] = prime_index(@number) if is_prime

      result
    end

    private

    def prime?(n)
      return false if n < 2
      return true if n < 4
      return false if n.even?
      return false if n % 3 == 0

      i = 5
      while i * i <= n
        return false if n % i == 0 || n % (i + 2) == 0
        i += 6
      end
      true
    end

    def factorize(n)
      return [] if n < 2
      factors = []
      d = 2
      temp = n
      while d * d <= temp
        while (temp % d).zero?
          factors << d
          temp /= d
        end
        d += 1
      end
      factors << temp if temp > 1
      factors
    end

    def nearest_prime_below(n)
      candidate = n - 1
      candidate -= 1 until candidate < 2 || prime?(candidate)
      candidate < 2 ? nil : candidate
    end

    def nearest_prime_above(n)
      candidate = n + 1
      limit = n + 1000
      candidate += 1 until candidate > limit || prime?(candidate)
      candidate > limit ? nil : candidate
    end

    def prime_index(n)
      return nil unless prime?(n)
      count = 0
      (2..n).each do |i|
        count += 1 if prime?(i)
        return count if i == n
      end
      count
    end

    def validate!
      @errors << "Number must be a positive integer greater than 1" if @number < 2
      @errors << "Number must be less than #{MAX_NUMBER}" if @number > MAX_NUMBER
    end
  end
end
