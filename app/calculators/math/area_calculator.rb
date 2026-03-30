module Math
  class AreaCalculator
    attr_reader :errors

    def initialize(shape:, **dimensions)
      @shape = shape.to_s
      @dimensions = dimensions.transform_values(&:to_f)
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      area = calculate_area

      {
        valid: true,
        area: area.round(4),
        shape: @shape
      }
    end

    private

    def calculate_area
      case @shape
      when "rectangle"
        @dimensions[:length] * @dimensions[:width]
      when "triangle"
        0.5 * @dimensions[:base] * @dimensions[:height]
      when "circle"
        ::Math::PI * @dimensions[:radius]**2
      when "trapezoid"
        0.5 * (@dimensions[:base1] + @dimensions[:base2]) * @dimensions[:height]
      when "ellipse"
        ::Math::PI * @dimensions[:semi_major] * @dimensions[:semi_minor]
      end
    end

    def validate!
      @errors << "Invalid shape" unless %w[rectangle triangle circle trapezoid ellipse].include?(@shape)
      @dimensions.each do |key, val|
        @errors << "#{key.to_s.humanize} must be positive" unless val > 0
      end
    end
  end
end
