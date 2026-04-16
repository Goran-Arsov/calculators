# frozen_string_literal: true

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
        x1_real = ((-@b + sqrt_disc) / (2 * @a)).round(4)
        x2_real = ((-@b - sqrt_disc) / (2 * @a)).round(4)
        root_type = discriminant.zero? ? "repeated" : "real"

        {
          valid: true,
          discriminant: discriminant.round(4),
          x1: x1_real.to_s,
          x2: x2_real.to_s,
          x1_real: x1_real,
          x1_imaginary: 0.0,
          x2_real: x2_real,
          x2_imaginary: 0.0,
          root_type: root_type,
          roots_type: root_type,
          vertex_x: vertex_x,
          vertex_y: vertex_y
        }
      else
        real_part = (-@b / (2 * @a)).round(4)
        imaginary_part = (::Math.sqrt(discriminant.abs) / (2 * @a)).round(4)

        {
          valid: true,
          discriminant: discriminant.round(4),
          x1: "#{real_part} + #{imaginary_part}i",
          x2: "#{real_part} - #{imaginary_part}i",
          x1_real: real_part,
          x1_imaginary: imaginary_part,
          x2_real: real_part,
          x2_imaginary: -imaginary_part,
          root_type: "complex",
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
