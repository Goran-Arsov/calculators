module Math
  class ScientificNotationCalculator
    attr_reader :errors

    def initialize(value:, mode: "to_scientific")
      @raw_value = value.to_s.strip
      @mode = mode.to_s
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      case @mode
      when "to_scientific"
        convert_to_scientific
      when "to_standard"
        convert_to_standard
      when "both"
        convert_both
      end
    end

    private

    def validate!
      @errors << "Value is required" if @raw_value.empty?
      @errors << "Invalid mode" unless %w[to_scientific to_standard both].include?(@mode)
      return if @errors.any?

      if @mode == "to_standard"
        unless @raw_value.match?(/\A[+-]?\d+(\.\d+)?[eE][+-]?\d+\z/)
          @errors << "Enter a valid scientific notation (e.g. 3.14e5)"
        end
      else
        begin
          Float(@raw_value)
        rescue ArgumentError, TypeError
          @errors << "Please enter a valid number"
        end
      end
    end

    def convert_to_scientific
      value = Float(@raw_value)

      if value.zero?
        return {
          valid: true,
          mode: @mode,
          input: @raw_value,
          coefficient: 0.0,
          exponent: 0,
          scientific: "0 x 10^0",
          e_notation: "0e0"
        }
      end

      exponent = ::Math.log10(value.abs).floor
      coefficient = value / (10.0**exponent)

      # Correct for floating-point edge cases
      if coefficient.abs >= 10.0
        exponent += 1
        coefficient = value / (10.0**exponent)
      elsif coefficient.abs < 1.0 && coefficient != 0.0
        exponent -= 1
        coefficient = value / (10.0**exponent)
      end

      {
        valid: true,
        mode: @mode,
        input: @raw_value,
        coefficient: coefficient.round(10),
        exponent: exponent,
        scientific: "#{coefficient.round(6)} x 10^#{exponent}",
        e_notation: "#{coefficient.round(6)}e#{exponent}",
        decimal: format_decimal(value)
      }
    end

    def convert_to_standard
      value = Float(@raw_value)

      parts = @raw_value.downcase.split("e")
      coefficient = parts[0].to_f
      exponent = parts[1].to_i

      {
        valid: true,
        mode: @mode,
        input: @raw_value,
        coefficient: coefficient.round(10),
        exponent: exponent,
        decimal: format_decimal(value),
        scientific: "#{coefficient.round(6)} x 10^#{exponent}",
        e_notation: @raw_value
      }
    end

    def convert_both
      value = Float(@raw_value)

      if value.zero?
        return {
          valid: true,
          mode: @mode,
          input: @raw_value,
          coefficient: 0.0,
          exponent: 0,
          scientific: "0 x 10^0",
          e_notation: "0e0",
          decimal: "0"
        }
      end

      exponent = ::Math.log10(value.abs).floor
      coefficient = value / (10.0**exponent)

      if coefficient.abs >= 10.0
        exponent += 1
        coefficient = value / (10.0**exponent)
      elsif coefficient.abs < 1.0 && coefficient != 0.0
        exponent -= 1
        coefficient = value / (10.0**exponent)
      end

      {
        valid: true,
        mode: @mode,
        input: @raw_value,
        coefficient: coefficient.round(10),
        exponent: exponent,
        scientific: "#{coefficient.round(6)} x 10^#{exponent}",
        e_notation: "#{coefficient.round(6)}e#{exponent}",
        decimal: format_decimal(value)
      }
    end

    def format_decimal(value)
      if value == value.to_i.to_f && value.abs < 1e15
        value.to_i.to_s
      else
        # Use BigDecimal for precise formatting of very large/small numbers
        format("%.15g", value)
      end
    end
  end
end
