module Finance
  class LoanCalculator
    attr_reader :errors

    def initialize(amount:, annual_rate:, years:)
      @amount = amount.to_f
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
        monthly_payment = @amount / num_payments
      else
        monthly_payment = @amount * (monthly_rate * (1 + monthly_rate)**num_payments) /
                          ((1 + monthly_rate)**num_payments - 1)
      end

      total_paid = monthly_payment * num_payments
      total_interest = total_paid - @amount

      {
        valid: true,
        monthly_payment: monthly_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments
      }
    end

    private

    def validate!
      @errors << "Loan amount must be positive" unless @amount > 0
      @errors << "Loan term must be positive" unless @years > 0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
    end
  end
end
