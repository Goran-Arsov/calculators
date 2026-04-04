module Math
  class QuadraticCalculator
    attr_reader :errors

    def initialize(a:, b:, c:)
      @a = a.to_f
      @b = b.to_f
      @c = c.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      discriminant = @b**2 - 4 * @a * @c
      vertex_x = (-@b / (2 * @a)).round(4)
      vertex_y = (@a * vertex_x**2 + @b * vertex_x + @c).round(4)

      if discriminant >= 0
        sqrt_disc = ::Math.sqrt(discriminant)
        x1 = ((-@b + sqrt_disc) / (2 * @a)).round(4)
        x2 = ((-@b - sqrt_disc) / (2 * @a)).round(4)

        {
          valid: true,
          discriminant: discriminant.round(4),
          x1: x1,
          x2: x2,
          roots_type: discriminant.zero? ? "repeated" : "real",
          vertex_x: vertex_x,
          vertex_y: vertex_y
        }
      else
        real_part = (-@b / (2 * @a)).round(4)
        imaginary_part = (::Math.sqrt(discriminant.abs) / (2 * @a)).round(4)

        x1 = "#{real_part} + #{imaginary_part}i"
        x2 = "#{real_part} - #{imaginary_part}i"

        {
          valid: true,
          discriminant: discriminant.round(4),
          x1: x1,
          x2: x2,
          roots_type: "complex",
          vertex_x: vertex_x,
          vertex_y: vertex_y
        }
      end
    end

    private

    def validate!
      @errors << "Coefficient a cannot be zero (not a quadratic equation)" if @a.zero?
    end
  end
end
