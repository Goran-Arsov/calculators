module Math
  class GcdLcmCalculator
    attr_reader :errors

    def initialize(a:, b:)
      @a = a.to_i
      @b = b.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      gcd = euclidean_gcd(@a, @b)
      lcm = (@a * @b).abs / gcd

      {
        valid: true,
        a: @a,
        b: @b,
        gcd: gcd,
        lcm: lcm
      }
    end

    private

    def euclidean_gcd(x, y)
      x = x.abs
      y = y.abs
      while y != 0
        x, y = y, x % y
      end
      x
    end

    def validate!
      @errors << "First number must be a positive integer" if @a <= 0
      @errors << "Second number must be a positive integer" if @b <= 0
    end
  end
end
