module Math
  class VectorCalculator
    OPERATIONS = %w[add subtract dot_product cross_product magnitude normalize scalar_multiply].freeze

    attr_reader :errors

    def initialize(operation:, vector1: [], vector2: [], scalar: 1)
      @operation = operation.to_s.strip.downcase
      @vector1 = parse_vector(vector1)
      @vector2 = parse_vector(vector2)
      @scalar = scalar.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result = compute
      result.merge(
        valid: true,
        operation: @operation,
        dimensions: determine_dimensions
      )
    end

    private

    def parse_vector(input)
      case input
      when Array
        input.map(&:to_f)
      when String
        input.split(",").map { |v| v.strip.to_f }
      else
        []
      end
    end

    def validate!
      @errors << "Operation cannot be blank" if @operation.empty?
      @errors << "Unsupported operation '#{@operation}'" unless OPERATIONS.include?(@operation)
      @errors << "Vector 1 must have 2 or 3 components" unless @vector1.length.between?(2, 3)

      needs_two = %w[add subtract dot_product cross_product]
      if needs_two.include?(@operation)
        @errors << "Vector 2 must have 2 or 3 components" unless @vector2.length.between?(2, 3)
        if @vector1.length != @vector2.length && @vector1.length.between?(2, 3) && @vector2.length.between?(2, 3)
          @errors << "Vectors must have the same number of dimensions"
        end
      end

      if @operation == "cross_product"
        @errors << "Cross product requires 3D vectors" unless @vector1.length == 3 && @vector2.length == 3
      end
    end

    def determine_dimensions
      @vector1.length == 3 ? "3D" : "2D"
    end

    def compute
      case @operation
      when "add" then add
      when "subtract" then subtract
      when "dot_product" then dot_product
      when "cross_product" then cross_product
      when "magnitude" then magnitude_op
      when "normalize" then normalize
      when "scalar_multiply" then scalar_multiply
      end
    end

    def add
      result = @vector1.zip(@vector2).map { |a, b| a + b }
      {
        result_vector: result,
        display: format_vector(result),
        v1: format_vector(@vector1),
        v2: format_vector(@vector2)
      }
    end

    def subtract
      result = @vector1.zip(@vector2).map { |a, b| a - b }
      {
        result_vector: result,
        display: format_vector(result),
        v1: format_vector(@vector1),
        v2: format_vector(@vector2)
      }
    end

    def dot_product
      result = @vector1.zip(@vector2).map { |a, b| a * b }.sum
      mag1 = compute_magnitude(@vector1)
      mag2 = compute_magnitude(@vector2)
      angle_rad = nil
      angle_deg = nil
      if mag1 > 0 && mag2 > 0
        cos_theta = [[-1.0, result / (mag1 * mag2)].max, 1.0].min
        angle_rad = ::Math.acos(cos_theta)
        angle_deg = angle_rad * 180.0 / ::Math::PI
      end

      {
        result_scalar: result,
        display: format_number(result),
        angle_radians: angle_rad,
        angle_degrees: angle_deg,
        v1: format_vector(@vector1),
        v2: format_vector(@vector2)
      }
    end

    def cross_product
      a = @vector1
      b = @vector2
      result = [
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0]
      ]
      mag = compute_magnitude(result)
      {
        result_vector: result,
        magnitude: mag,
        display: format_vector(result),
        v1: format_vector(@vector1),
        v2: format_vector(@vector2)
      }
    end

    def magnitude_op
      mag = compute_magnitude(@vector1)
      {
        magnitude: mag,
        display: format_number(mag),
        v1: format_vector(@vector1)
      }
    end

    def normalize
      mag = compute_magnitude(@vector1)
      if mag.zero?
        @errors << "Cannot normalize a zero vector"
        return { display: "undefined" }
      end
      result = @vector1.map { |c| c / mag }
      {
        result_vector: result,
        display: format_vector(result),
        magnitude: mag,
        v1: format_vector(@vector1)
      }
    end

    def scalar_multiply
      result = @vector1.map { |c| c * @scalar }
      {
        result_vector: result,
        display: format_vector(result),
        scalar: @scalar,
        v1: format_vector(@vector1)
      }
    end

    def compute_magnitude(v)
      ::Math.sqrt(v.map { |c| c**2 }.sum)
    end

    def format_vector(v)
      components = v.map { |c| format_number(c) }
      "\u27E8#{components.join(', ')}\u27E9"
    end

    def format_number(n)
      return "0" if n.abs < 1e-12
      if n == n.to_i.to_f && n.abs < 1e12
        n.to_i.to_s
      else
        ("%.6g" % n)
      end
    end
  end
end
