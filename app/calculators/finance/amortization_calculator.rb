module Finance
  class AmortizationCalculator
    attr_reader :errors

    def initialize(principal:, annual_rate:, years:)
      @principal = principal.to_f
      @annual_rate = annual_rate.to_f / 100.0
      @years = years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      monthly_rate = @annual_rate / 12.0
      num_payments = @years * 12

      if monthly_rate.zero?
        monthly_payment = @principal / num_payments
      else
        monthly_payment = @principal * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      schedule = []
      balance = @principal
      total_interest = 0.0
      total_principal_paid = 0.0

      num_payments.times do |i|
        interest_payment = balance * monthly_rate
        principal_payment = monthly_payment - interest_payment
        # Last payment adjustment to zero out balance
        if i == num_payments - 1
          principal_payment = balance
          monthly_payment_actual = principal_payment + interest_payment
        else
          monthly_payment_actual = monthly_payment
        end

        balance -= principal_payment
        balance = 0.0 if balance < 0.01
        total_interest += interest_payment
        total_principal_paid += principal_payment

        schedule << {
          month: i + 1,
          payment: monthly_payment_actual.round(2),
          principal: principal_payment.round(2),
          interest: interest_payment.round(2),
          balance: balance.round(2)
        }
      end

      {
        valid: true,
        monthly_payment: monthly_payment.round(2),
        total_paid: (monthly_payment * num_payments).round(2),
        total_interest: total_interest.round(2),
        principal: @principal.round(2),
        num_payments: num_payments,
        schedule: schedule
      }
    end

    private

    def validate!
      @errors << "Principal must be positive" unless @principal > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
