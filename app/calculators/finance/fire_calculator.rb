module Finance
  class FireCalculator
    attr_reader :errors

    def initialize(annual_expenses:, annual_savings:, current_portfolio:, expected_return_rate:, safe_withdrawal_rate: 4)
      @annual_expenses = annual_expenses.to_f
      @annual_savings = annual_savings.to_f
      @current_portfolio = current_portfolio.to_f
      @expected_return_rate = expected_return_rate.to_f / 100.0
      @safe_withdrawal_rate = safe_withdrawal_rate.to_f / 100.0
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      fire_number = @annual_expenses / @safe_withdrawal_rate

      if @current_portfolio >= fire_number
        years_to_fire = 0
        projected_portfolio_at_fire = @current_portfolio
      else
        years_to_fire = calculate_years_to_fire(fire_number)
        projected_portfolio_at_fire = fire_number
      end

      monthly_savings_needed = if years_to_fire.zero?
                                  0.0
                                else
                                  calculate_monthly_savings_needed(fire_number, years_to_fire)
                                end

      {
        valid: true,
        fire_number: fire_number.round(2),
        years_to_fire: years_to_fire,
        monthly_savings_needed: monthly_savings_needed.round(2),
        projected_portfolio_at_fire: projected_portfolio_at_fire.round(2)
      }
    end

    private

    def validate!
      @errors << "Annual expenses must be positive" unless @annual_expenses > 0
      @errors << "Annual savings cannot be negative" if @annual_savings < 0
      @errors << "Current portfolio cannot be negative" if @current_portfolio < 0
      @errors << "Expected return rate cannot be negative" if @expected_return_rate < 0
      @errors << "Safe withdrawal rate must be positive" unless @safe_withdrawal_rate > 0
    end

    def calculate_years_to_fire(fire_number)
      if @expected_return_rate.zero?
        gap = fire_number - @current_portfolio
        return 0 if @annual_savings.zero?
        (gap / @annual_savings).ceil
      else
        # Solve for n: current_portfolio * (1+r)^n + annual_savings * ((1+r)^n - 1) / r = fire_number
        # Rearranging: (current_portfolio + annual_savings/r) * (1+r)^n = fire_number + annual_savings/r
        # (1+r)^n = (fire_number + annual_savings/r) / (current_portfolio + annual_savings/r)
        r = @expected_return_rate
        numerator = fire_number + @annual_savings / r
        denominator = @current_portfolio + @annual_savings / r

        return 0 if denominator <= 0 || numerator <= 0 || numerator <= denominator

        years = Math.log(numerator / denominator) / Math.log(1 + r)
        years.ceil
      end
    end

    def calculate_monthly_savings_needed(fire_number, years)
      # How much monthly savings needed to reach fire_number in the given years
      # FV = PV*(1+r/12)^(n*12) + PMT*((1+r/12)^(n*12)-1)/(r/12) = fire_number
      # PMT = (fire_number - PV*(1+r/12)^(n*12)) / (((1+r/12)^(n*12)-1)/(r/12))
      monthly_rate = @expected_return_rate / 12.0
      num_months = years * 12

      if monthly_rate.zero?
        gap = fire_number - @current_portfolio
        gap / num_months.to_f
      else
        future_value_of_current = @current_portfolio * (1 + monthly_rate)**num_months
        remaining = fire_number - future_value_of_current
        annuity_factor = ((1 + monthly_rate)**num_months - 1) / monthly_rate
        remaining / annuity_factor
      end
    end
  end
end
