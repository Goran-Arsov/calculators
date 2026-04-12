module Finance
  class HelocCalculator
    attr_reader :errors

    def initialize(home_value:, mortgage_balance:, credit_limit_percent:, annual_rate:, draw_amount:, repayment_years:)
      @home_value = home_value.to_f
      @mortgage_balance = mortgage_balance.to_f
      @credit_limit_percent = credit_limit_percent.to_f / 100.0
      @annual_rate = annual_rate.to_f / 100.0
      @draw_amount = draw_amount.to_f
      @repayment_years = repayment_years.to_i
      @errors = []
    end

    def call
      validate!
      return { valid: false, errors: @errors } if @errors.any?

      available_equity = (@home_value * @credit_limit_percent) - @mortgage_balance
      available_equity = [ available_equity, 0 ].max

      monthly_rate = @annual_rate / 12.0
      num_payments = @repayment_years * 12

      if @draw_amount > 0 && num_payments > 0
        if monthly_rate.zero?
          monthly_payment = @draw_amount / num_payments.to_f
        else
          monthly_payment = @draw_amount * (monthly_rate * (1 + monthly_rate)**num_payments) /
                            ((1 + monthly_rate)**num_payments - 1)
        end
        total_paid = monthly_payment * num_payments
        total_interest = total_paid - @draw_amount
      else
        monthly_payment = 0.0
        total_paid = 0.0
        total_interest = 0.0
      end

      interest_only_payment = @draw_amount * monthly_rate

      {
        valid: true,
        available_equity: available_equity.round(2),
        monthly_payment: monthly_payment.round(2),
        interest_only_payment: interest_only_payment.round(2),
        total_paid: total_paid.round(2),
        total_interest: total_interest.round(2),
        num_payments: num_payments,
        draw_amount: @draw_amount.round(2)
      }
    end

    private

    def validate!
      @errors << "Home value must be positive" unless @home_value > 0
      @errors << "Mortgage balance cannot be negative" if @mortgage_balance < 0
      @errors << "Credit limit percent must be between 0 and 100" unless @credit_limit_percent > 0 && @credit_limit_percent <= 1.0
      @errors << "Interest rate cannot be negative" if @annual_rate < 0
      @errors << "Draw amount cannot be negative" if @draw_amount < 0
      @errors << "Repayment term must be positive" unless @repayment_years > 0
    end
  end
end
