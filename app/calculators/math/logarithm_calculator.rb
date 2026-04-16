# frozen_string_literal: true

module Math
  class LogarithmCalculator
    attr_reader :errors

    def initialize(value:, base: "e")
      @value = value.to_f
      @base_raw = base.to_s.strip
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      ln_value = ::Math.log(@value)
      log10_value = ::Math.log10(@value)

      custom_result = if @base_raw == "e"
                        ln_value
      elsif @base_raw == "10"
                        log10_value
      else
                        base_num = @base_raw.to_f
                        ::Math.log(@value) / ::Math.log(base_num)
      end

      {
        valid: true,
        value: @value,
        base: @base_raw,
        result: custom_result.round(8),
        ln: ln_value.round(8),
        log10: log10_value.round(8),
        log2: (::Math.log2(@value)).round(8)
      }
    end

    private

    def validate!
      @errors << "Value must be a positive number" if @value <= 0
      unless @base_raw == "e" || valid_base?
        @errors << "Base must be 'e', or a positive number not equal to 1"
      end
    end

    def valid_base?
      base_num = Float(@base_raw)
      base_num > 0 && base_num != 1
    rescue ArgumentError, TypeError
      false
    end
  end
end
