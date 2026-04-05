module Math
  class SigFigsCalculator
    attr_reader :errors

    def initialize(value:, round_to: nil)
      @raw_value = value.to_s.strip
      @round_to = round_to.nil? || round_to.to_s.strip.empty? ? nil : round_to.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      sig_fig_count = count_sig_figs(@raw_value)
      numeric_value = Float(@raw_value)

      result = {
        valid: true,
        input: @raw_value,
        sig_figs: sig_fig_count,
        scientific_notation: to_scientific(numeric_value),
        numeric_value: numeric_value
      }

      if @round_to
        rounded = round_to_sig_figs(numeric_value, @round_to)
        result[:rounded_to] = @round_to
        result[:rounded_value] = rounded
      end

      result
    end

    private

    def validate!
      begin
        Float(@raw_value)
      rescue ArgumentError, TypeError
        @errors << "Please enter a valid number"
        return
      end

      @errors << "Value is required" if @raw_value.empty?
      @errors << "Round-to must be a positive integer" if @round_to && @round_to < 1
    end

    def count_sig_figs(value_str)
      str = value_str.strip
      str = str.sub(/\A[+-]/, "")

      # Handle scientific notation
      if str =~ /\A([^eE]+)[eE]/
        str = $1
      end

      return 0 if str.empty?

      if str.include?(".")
        # With decimal point
        integer_part, decimal_part = str.split(".", 2)
        integer_part = integer_part.to_s

        if integer_part.gsub(/\A0+/, "").empty?
          # 0.00xyz — leading zeros in decimal don't count
          stripped = decimal_part.sub(/\A0*/, "")
          stripped.length
        else
          # Has non-zero integer part: all digits count except leading zeros
          all_digits = integer_part + decimal_part
          all_digits.sub(/\A0+/, "").length
        end
      else
        # No decimal point
        stripped = str.sub(/\A0+/, "")
        return 1 if stripped.empty?
        # Trailing zeros without decimal point are ambiguous — count them as not significant
        stripped.sub(/0+\z/, "").length.zero? ? 1 : stripped.sub(/0+\z/, "").length
      end
    end

    def round_to_sig_figs(value, sig_figs)
      return 0.0 if value.zero?

      d = (::Math.log10(value.abs).floor + 1).to_i
      power = sig_figs - d
      magnitude = 10.0**power
      (value * magnitude).round / magnitude
    end

    def to_scientific(value)
      return "0" if value.zero?
      format("%.6e", value)
    end
  end
end
