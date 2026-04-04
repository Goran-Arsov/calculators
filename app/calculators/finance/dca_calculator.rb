module Finance
  class DcaCalculator
    attr_reader :errors

    def initialize(monthly_investment:, annual_return:, years:)
      @monthly_investment = monthly_investment.to_f
      @annual_return = annual_return.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      total_invested = @monthly_investment * @years * 12
      monthly_rate = @annual_return / 12.0
      num_payments = @years * 12

      if monthly_rate.zero?
        future_value = total_invested
      else
        # Future value of annuity: PMT × ((1 + r)^n - 1) / r
        future_value = @monthly_investment * (((1 + monthly_rate)**num_payments - 1) / monthly_rate)
      end

      total_return = future_value - total_invested

      {
        valid: true,
        total_invested: total_invested.round(4),
        future_value: future_value.round(4),
        total_return: total_return.round(4),
        monthly_investment: @monthly_investment.round(4),
        annual_return: (@annual_return * 100.0).round(4),
        years: @years
      }
    end

    private

    def validate!
      @errors << "Monthly investment must be positive" unless @monthly_investment > 0
      @errors << "Annual return cannot be negative" if @annual_return < 0
      @errors << "Years must be positive" unless @years > 0
    end
  end
end
