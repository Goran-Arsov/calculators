module Math
  class PythagoreanCalculator
    attr_reader :errors

    def initialize(a: nil, b: nil, c: nil)
      @a = a.present? ? a.to_f : nil
      @b = b.present? ? b.to_f : nil
      @c = c.present? ? c.to_f : nil
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      if @a.nil?
        solved_a = ::Math.sqrt(@c**2 - @b**2)
        {
          valid: true,
          a: solved_a.round(4),
          b: @b.round(4),
          c: @c.round(4),
          solved_for: "a"
        }
      elsif @b.nil?
        solved_b = ::Math.sqrt(@c**2 - @a**2)
        {
          valid: true,
          a: @a.round(4),
          b: solved_b.round(4),
          c: @c.round(4),
          solved_for: "b"
        }
      else
        solved_c = ::Math.sqrt(@a**2 + @b**2)
        {
          valid: true,
          a: @a.round(4),
          b: @b.round(4),
          c: solved_c.round(4),
          solved_for: "c"
        }
      end
    end

    private

    def validate!
      provided = { a: @a, b: @b, c: @c }.compact
      @errors << "Exactly 2 sides must be provided" if provided.size != 2

      provided.each do |name, value|
        @errors << "Side #{name} must be positive" if value <= 0
      end

      return if @errors.any?

      if @a.nil? && @c**2 - @b**2 < 0
        @errors << "Hypotenuse c must be greater than side b"
      elsif @b.nil? && @c**2 - @a**2 < 0
        @errors << "Hypotenuse c must be greater than side a"
      end
    end
  end
end
