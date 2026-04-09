module Finance
  class DownPaymentCalculator
    attr_reader :errors

    def initialize(home_price:, down_payment_percent: 20, current_savings:, monthly_savings:, annual_return_rate:)
      @home_price = home_price.to_f
      @down_payment_percent = down_payment_percent.to_f
      @current_savings = current_savings.to_f
      @monthly_savings = monthly_savings.to_f
      @annual_return_rate = annual_return_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      down_payment_target = @home_price * (@down_payment_percent / 100.0)
      savings_gap = down_payment_target - @current_savings

      if savings_gap <= 0
        return {
          valid: true,
          down_payment_target: down_payment_target.round(2),
          savings_gap: 0.0,
          months_to_save: 0,
          years_to_save: 0.0,
          total_with_interest: @current_savings.round(2)
        }
      end

      months_to_save = calculate_months_to_save(down_payment_target)
      years_to_save = months_to_save / 12.0
      total_with_interest = calculate_total_with_interest(months_to_save)

      {
        valid: true,
        down_payment_target: down_payment_target.round(2),
        savings_gap: savings_gap.round(2),
        months_to_save: months_to_save,
        years_to_save: years_to_save.round(1),
        total_with_interest: total_with_interest.round(2)
      }
    end

    private

    def validate!
      @errors << "Home price must be positive" unless @home_price > 0
      @errors << "Down payment percent must be positive" unless @down_payment_percent > 0
      @errors << "Down payment percent cannot exceed 100" if @down_payment_percent > 100
      @errors << "Current savings cannot be negative" if @current_savings < 0
      @errors << "Monthly savings must be positive" unless @monthly_savings > 0
      @errors << "Annual return rate cannot be negative" if @annual_return_rate < 0
    end

    def calculate_months_to_save(target)
      monthly_rate = @annual_return_rate / 12.0

      if monthly_rate.zero?
        gap = target - @current_savings
        return 0 if @monthly_savings.zero?
        (gap / @monthly_savings).ceil
      else
        # Solve for n: current_savings * (1+r)^n + monthly_savings * ((1+r)^n - 1) / r = target
        # (current_savings + monthly_savings/r) * (1+r)^n = target + monthly_savings/r
        numerator = target + @monthly_savings / monthly_rate
        denominator = @current_savings + @monthly_savings / monthly_rate

        return 0 if denominator <= 0 || numerator <= denominator

        months = Math.log(numerator / denominator) / Math.log(1 + monthly_rate)
        months.ceil
      end
    end

    def calculate_total_with_interest(months)
      monthly_rate = @annual_return_rate / 12.0

      if monthly_rate.zero?
        @current_savings + @monthly_savings * months
      else
        @current_savings * (1 + monthly_rate)**months +
          @monthly_savings * ((1 + monthly_rate)**months - 1) / monthly_rate
      end
    end
  end
end
