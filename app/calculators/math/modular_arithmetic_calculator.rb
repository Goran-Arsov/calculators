module Math
  class ModularArithmeticCalculator
    OPERATIONS = %w[add subtract multiply exponentiate inverse].freeze

    attr_reader :errors

    def initialize(a:, b: 0, modulus:, operation:)
      @a = a.to_i
      @b = b.to_i
      @modulus = modulus.to_i
      @operation = operation.to_s.strip.downcase
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = compute
      result.merge(
        valid: true,
        a: @a,
        b: @b,
        modulus: @modulus,
        operation: @operation
      )
    end

    private

    def validate!
      @errors << "Operation cannot be blank" if @operation.empty?
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
      @errors << "Modulus must be a positive integer greater than 1" if @modulus <= 1
      if @operation == "exponentiate" && @b < 0
        @errors << "Exponent must be non-negative for modular exponentiation"
      end
    end

    def compute
      case @operation
      when "add" then mod_add
      when "subtract" then mod_subtract
      when "multiply" then mod_multiply
      when "exponentiate" then mod_exponentiate
      when "inverse" then mod_inverse
      end
    end

    def mod_add
      result = (@a + @b) % @modulus
      {
        result: result,
        display: "#{@a} + #{@b} \u2261 #{result} (mod #{@modulus})",
        formula: "(#{@a} + #{@b}) mod #{@modulus} = #{result}"
      }
    end

    def mod_subtract
      result = (@a - @b) % @modulus
      {
        result: result,
        display: "#{@a} - #{@b} \u2261 #{result} (mod #{@modulus})",
        formula: "(#{@a} - #{@b}) mod #{@modulus} = #{result}"
      }
    end

    def mod_multiply
      result = (@a * @b) % @modulus
      {
        result: result,
        display: "#{@a} * #{@b} \u2261 #{result} (mod #{@modulus})",
        formula: "(#{@a} * #{@b}) mod #{@modulus} = #{result}"
      }
    end

    def mod_exponentiate
      result = fast_power(@a, @b, @modulus)
      {
        result: result,
        display: "#{@a}^#{@b} \u2261 #{result} (mod #{@modulus})",
        formula: "#{@a}^#{@b} mod #{@modulus} = #{result}",
        method: "Fast exponentiation (binary method)"
      }
    end

    def mod_inverse
      g, x, = extended_gcd(@a % @modulus, @modulus)
      if g != 1
        {
          result: nil,
          exists: false,
          display: "No inverse exists (gcd(#{@a}, #{@modulus}) = #{g} \u2260 1)",
          formula: "#{@a} has no modular inverse mod #{@modulus}"
        }
      else
        result = x % @modulus
        {
          result: result,
          exists: true,
          display: "#{@a}\u207B\u00B9 \u2261 #{result} (mod #{@modulus})",
          formula: "#{@a} * #{result} \u2261 1 (mod #{@modulus})",
          verification: (@a * result) % @modulus
        }
      end
    end

    # Binary exponentiation: computes base^exp mod m
    def fast_power(base, exp, m)
      result = 1
      base = base % m
      while exp > 0
        result = (result * base) % m if exp.odd?
        exp >>= 1
        base = (base * base) % m
      end
      result
    end

    # Extended Euclidean Algorithm: returns [gcd, x, y] where a*x + b*y = gcd
    def extended_gcd(a, b)
      return [ a, 1, 0 ] if b.zero?
      g, x, y = extended_gcd(b, a % b)
      [ g, y, x - (a / b) * y ]
    end
  end
end
