module Math
  class FractionCalculator
    attr_reader :errors

    def initialize(num1:, den1:, num2:, den2:, operation:)
      @num1 = num1.to_i
      @den1 = den1.to_i
      @num2 = num2.to_i
      @den2 = den2.to_i
      @operation = operation.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      result_num, result_den = compute
      gcd = result_num.gcd(result_den)
      simplified_num = result_num / gcd
      simplified_den = result_den / gcd

      # Ensure negative sign is on numerator
      if simplified_den < 0
        simplified_num = -simplified_num
        simplified_den = -simplified_den
      end

      {
        valid: true,
        numerator: simplified_num,
        denominator: simplified_den,
        decimal: (simplified_num.to_f / simplified_den).round(6),
        operation: @operation
      }
    end

    private

    def compute
      case @operation
      when "add"
        [ @num1 * @den2 + @num2 * @den1, @den1 * @den2 ]
      when "subtract"
        [ @num1 * @den2 - @num2 * @den1, @den1 * @den2 ]
      when "multiply"
        [ @num1 * @num2, @den1 * @den2 ]
      when "divide"
        [ @num1 * @den2, @den1 * @num2 ]
      end
    end

    def validate!
      @errors << "First denominator cannot be zero" if @den1.zero?
      @errors << "Second denominator cannot be zero" if @den2.zero?
      @errors << "Cannot divide by zero" if @operation == "divide" && @num2.zero?
      @errors << "Invalid operation" unless %w[add subtract multiply divide].include?(@operation)
    end
  end
end
