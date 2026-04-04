module Finance
  class InflationCalculator
    attr_reader :errors

    def initialize(present_value:, rate:, years:)
      @present_value = present_value.to_f
      @rate = rate.to_f / 100.0
      @years = years.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      future_value = @present_value * (1 + @rate)**@years
      purchasing_power_loss = future_value - @present_value

      {
        valid: true,
        future_value: future_value.round(4),
        purchasing_power_loss: purchasing_power_loss.round(4),
        present_value: @present_value.round(4),
        rate: (@rate * 100.0).round(4),
        years: @years.round(4)
      }
    end

    private

    def validate!
      @errors << "Present value must be positive" unless @present_value > 0
      @errors << "Inflation rate cannot be negative" if @rate < 0
      @errors << "Years must be positive" unless @years > 0
    end
  end
end
