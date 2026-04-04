module Finance
  class CreditCardPayoffCalculator
    attr_reader :errors

    MAX_MONTHS = 1200  # 100 years safety cap

    def initialize(balance:, apr:, monthly_payment:)
      @balance = balance.to_f
      @apr = apr.to_f / 100.0
      @monthly_payment = monthly_payment.to_f
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @apr / 12.0
      remaining = @balance
      total_interest = 0.0
      months = 0
      schedule = []

      while remaining > 0.01 && months < MAX_MONTHS
        interest_charge = remaining * monthly_rate
        payment = [@monthly_payment, remaining + interest_charge].min
        principal_paid = payment - interest_charge

        # If payment does not cover interest, debt grows forever
        if principal_paid <= 0 && months > 0
          return {
            valid: false,
            errors: ["Monthly payment of #{format('$%.2f', @monthly_payment)} does not cover the monthly interest of #{format('$%.2f', interest_charge)}. Increase your payment to at least #{format('$%.2f', interest_charge + 0.01)} to make progress."]
          }
        end

        remaining -= principal_paid
        remaining = 0.0 if remaining < 0.01
        total_interest += interest_charge
        months += 1

        schedule << {
          month: months,
          payment: payment.round(2),
          principal: principal_paid.round(2),
          interest: interest_charge.round(2),
          balance: remaining.round(2)
        }
      end

      total_paid = @balance + total_interest
      payoff_date = Date.today >> months

      {
        valid: true,
        balance: @balance.round(2),
        apr: (@apr * 100).round(2),
        monthly_payment: @monthly_payment.round(2),
        months_to_payoff: months,
        years_to_payoff: (months / 12.0).round(1),
        total_interest: total_interest.round(2),
        total_paid: total_paid.round(2),
        payoff_date: payoff_date.strftime("%B %Y"),
        schedule: schedule
      }
    end

    private

    def validate!
      @errors << "Balance must be positive" unless @balance > 0
      @errors << "APR cannot be negative" if @apr < 0
      @errors << "Monthly payment must be positive" unless @monthly_payment > 0
    end
  end
end
